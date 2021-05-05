//
//  ColorMap.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/26/21.
//

import Foundation
import UIKit
import CoreMedia
import CoreVideo
import MetalKit

class ColorMap: MetalFilterParent, BuiltInFilterProtocol
{
    // MARK: - Required by BuiltInFilterProtocol.
    
    static var FilterType: BuiltInFilters = .ColorMap
    var NeedsInitialization: Bool = true

    // MARK: - Class variables.
    
    private let MetalDevice = MTLCreateSystemDefaultDevice()
    private var ComputePipelineState: MTLComputePipelineState? = nil
    private lazy var CommandQueue: MTLCommandQueue? =
        {
            return self.MetalDevice?.makeCommandQueue()
        }()
    private(set) var OutputFormatDescription: CMFormatDescription? = nil
    private(set) var InputFormatDescription: CMFormatDescription? = nil
    private var LocalBufferPool: CVPixelBufferPool? = nil
    var Initialized = false
    var ParameterBuffer: MTLBuffer! = nil
    
    override required init()
    {
        print("Metal kernel function ColorMap initialized")
        let DefaultLibrary = MetalDevice?.makeDefaultLibrary()
        let KernelFunction = DefaultLibrary?.makeFunction(name: "ColorMap")
        do
        {
            ComputePipelineState = try MetalDevice?.makeComputePipelineState(function: KernelFunction!)
        }
        catch
        {
            print("Unable to create pipeline state in ColorMap: \(error.localizedDescription)")
        }
    }
    
    func Initialize(With FormatDescription: CMFormatDescription, BufferCountHint: Int)
    {
        if Initialized
        {
            return
        }

        Reset()
        (LocalBufferPool, _, OutputFormatDescription) = CreateBufferPool(From: FormatDescription,
                                                                    BufferCountHint: BufferCountHint)
        guard LocalBufferPool != nil else
        {
            print("LocalBufferPool is nil in ColorMap.Initialize.")
            return
        }
        InputFormatDescription = FormatDescription
        Initialized = true
        var MetalTextureCache: CVMetalTextureCache? = nil
        guard CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, MetalDevice!, nil, &MetalTextureCache) == kCVReturnSuccess else
        {
            fatalError("Unable to allocate texture cache in ColorMap.")
        }
        TextureCache = MetalTextureCache
    }
    
    let AccessLock = NSObject()
    
    func Reset()
    {
        objc_sync_enter(AccessLock)
        defer{objc_sync_exit(AccessLock)}
        LocalBufferPool = nil
        OutputFormatDescription = nil
        InputFormatDescription = nil
        TextureCache = nil
        Initialized = false
    }
    
    func RunFilter(_ Buffer: [CVPixelBuffer], _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace, Options: [FilterOptions: Any]) -> CVPixelBuffer
    {
        if !Initialized
        {
            fatalError("ColorMap not initialized.")
        }
        objc_sync_enter(AccessLock)
        defer{objc_sync_exit(AccessLock)}
        
        let Parameter = ColorMapParameters(InvertGradientDirection: false, InvertGradientValues: false)
        let Parameters = [Parameter]
        ParameterBuffer = MetalDevice!.makeBuffer(length: MemoryLayout<ColorMapParameters>.stride,
                                                  options: [])
        memcpy(ParameterBuffer.contents(), Parameters, MemoryLayout<ColorMapParameters>.stride)
        
        var NewPixelBuffer: CVPixelBuffer? = nil
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, LocalBufferPool!, &NewPixelBuffer)
        guard var OutputBuffer = NewPixelBuffer else
        {
            fatalError("Error creating textures for ColorMap.")
        }
        guard let InputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: Buffer.first!, TextureFormat: .bgra8Unorm),
              let OutputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: OutputBuffer, TextureFormat: .bgra8Unorm) else
        {
            fatalError("Error creating textures in ColorMap.")
        }
        
        guard let CommandQ = CommandQueue,
              let CommandBuffer = CommandQ.makeCommandBuffer(),
              let CommandEncoder = CommandBuffer.makeComputeCommandEncoder() else
        {
            fatalError("Error creating Metal command queue.")
        }
        
        #if true
        guard let GradDef = Options[.GradientDefinition] as? String ?? Settings.SettingDefaults[.ColorMapGradient] as? String else
        {
            fatalError("Error getting color map gradient definition.")
        }
        let ActualGradient = GradientManager.ResolveGradient(GradDef)
        #else
        let First = Options[.Color0] as? UIColor ?? UIColor.red
        let Second = Options[.Color1] as? UIColor ?? UIColor.blue
        let GradientDescription = GradientManager.AssembleGradient([(First, 0.0),(Second, 1.0)])
        let ActualGradient = GradientManager.ResolveGradient(GradientDescription)
        #endif
        var GradientData = [simd_float4](repeating: simd_float4(0.0, 0.0, 0.0, 0.0), count: 256)
        for Index in 0 ... 255
        {
            let Color = ActualGradient[Index]
            GradientData[Index] = simd_float4(Float(Color.r), Float(Color.g), Float(Color.b), 1.0)
        }
        let IGPtr = UnsafePointer(GradientData)
        let GradientBufferSize = MemoryLayout<simd_float4>.stride * 256
        let GradientBuffer = MetalDevice!.makeBuffer(bytes: IGPtr, length: GradientBufferSize, options: [])
        
        let ResultsCount = 10
        let ResultsBuffer = MetalDevice!.makeBuffer(length: MemoryLayout<ReturnBufferType>.stride * ResultsCount, options: [])
        let Results = UnsafeBufferPointer<ReturnBufferType>(start: UnsafePointer(ResultsBuffer!.contents().assumingMemoryBound(to: ReturnBufferType.self)),
                                                            count: ResultsCount)
        
        CommandEncoder.label = "Color Map Kernel"
        CommandEncoder.setComputePipelineState(ComputePipelineState!)
        CommandEncoder.setTexture(InputTexture, index: 0)
        CommandEncoder.setTexture(OutputTexture, index: 1)
        CommandEncoder.setBuffer(ParameterBuffer, offset: 0, index: 0)
        CommandEncoder.setBuffer(ResultsBuffer, offset: 0, index: 2)
        CommandEncoder.setBuffer(GradientBuffer, offset: 0, index: 1)
        
        let w = ComputePipelineState!.threadExecutionWidth
        let h = ComputePipelineState!.maxTotalThreadsPerThreadgroup / w
        let ThreadsPerThreadGroup = MTLSize(width: w, height: h, depth: 1)
        let ThreadGroupsPerGrid = MTLSize(width: (InputTexture.width + w - 1) / w,
                                          height: (InputTexture.height + h - 1) / h,
                                          depth: 1)
        CommandEncoder.dispatchThreadgroups(ThreadGroupsPerGrid, threadsPerThreadgroup: ThreadsPerThreadGroup)
        CommandEncoder.endEncoding()
        CommandBuffer.commit()
        CommandBuffer.waitUntilCompleted()
        
        if Options[.Merge] as? Bool ?? false
        {
            print("Merging color map to original")
            let MaskFilter = Masking1()
            MaskFilter.Initialize(With: InputFormatDescription!, BufferCountHint: 3)
            OutputBuffer = MaskFilter.RenderWith(PixelBuffer: Buffer, And: OutputBuffer)!
        }
        
        return OutputBuffer
    }
}
