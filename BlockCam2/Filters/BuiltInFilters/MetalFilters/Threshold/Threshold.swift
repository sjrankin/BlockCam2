//
//  Threshold.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/13/21.
//

import Foundation
import UIKit
import CoreMedia
import CoreVideo
import MetalKit

class Threshold: MetalFilterParent, BuiltInFilterProtocol
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
        print("Metal kernel function Threshold initialized")
        let DefaultLibrary = MetalDevice?.makeDefaultLibrary()
        let KernelFunction = DefaultLibrary?.makeFunction(name: "ThresholdKernel")
        do
        {
            ComputePipelineState = try MetalDevice?.makeComputePipelineState(function: KernelFunction!)
        }
        catch
        {
            print("Unable to create pipeline state in Threshold: \(error.localizedDescription)")
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
            fatalError("Threshold not initialized.")
        }
        objc_sync_enter(AccessLock)
        defer{objc_sync_exit(AccessLock)}
        
        let TValue = Options[.Threshold] as? Double ?? 0.5
        let TInput = Options[.ThresholdInput] as? Int ?? 0
        let ApplyIfBig = Options[.ApplyIfHigher] as? Bool ?? false
        let LowColor = Options[.LowColor] as? UIColor ?? UIColor.black
        let HighColor = Options[.HighColor] as? UIColor ?? UIColor.white
        let Parameter = ThresholdParameters(ThresholdValue: simd_float1(TValue),
                                            ThresholdInput: simd_uint1(TInput),
                                            ApplyIfHigher: simd_bool(ApplyIfBig),
                                            LowColor: LowColor.ToFloat4(),
                                            HighColor: HighColor.ToFloat4())
        let Parameters = [Parameter]
        ParameterBuffer = MetalDevice!.makeBuffer(length: MemoryLayout<ThresholdParameters>.stride, options: [])
        memcpy(ParameterBuffer.contents(), Parameters, MemoryLayout<ThresholdParameters>.stride)
        
        #if true
        super.CreateBufferPool(Source: CIImage(cvPixelBuffer: Buffer.first!), From: Buffer.first!)
        var NewPixelBuffer: CVPixelBuffer? = nil
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, super.BasePool!, &NewPixelBuffer)
        guard var OutputBuffer = NewPixelBuffer else
        {
            Debug.FatalError("Error creation textures for Threshold.")
        }
        #else
        guard let Format = FilterHelper.GetFormatDescription(From: Buffer.first!) else
        {
            Debug.FatalError("Error getting description of buffer in Threshold.")
        }
        let ImageSize = CGSize(width: Int(Format.dimensions.width), height: Int(Format.dimensions.height))
        guard let LocalBufferPool = FilterHelper.CreateBufferPool(From: Format,
                                                                  BufferCountHint: 3,
                                                                  BufferSize: ImageSize) else
        {
            Debug.FatalError("Error creating local buffer pool in Threshold.")
        }
        var NewPixelBuffer: CVPixelBuffer? = nil
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, LocalBufferPool, &NewPixelBuffer)
        guard var OutputBuffer = NewPixelBuffer else
        {
            Debug.FatalError("Error creating textures for Threshold.")
        }
        #endif
        
        guard let InputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: Buffer.first!, TextureFormat: .bgra8Unorm) else
        {
            Debug.FatalError("Error creating input texture in Threshold.")
        }
        guard let OutputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: OutputBuffer, TextureFormat: .bgra8Unorm) else
        {
            Debug.FatalError("Error creating output texture in Threshold.")
        }
        
        guard let CommandQ = CommandQueue,
              let CommandBuffer = CommandQ.makeCommandBuffer(),
              let CommandEncoder = CommandBuffer.makeComputeCommandEncoder() else
        {
            Debug.FatalError("Error creating Metal command queue.")
        }
        
        CommandEncoder.label = "Threshold Kernel"
        CommandEncoder.setComputePipelineState(ComputePipelineState!)
        CommandEncoder.setTexture(InputTexture, index: 0)
        CommandEncoder.setTexture(OutputTexture, index: 1)
        CommandEncoder.setBuffer(ParameterBuffer, offset: 0, index: 0)
        
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
    
    /// Reset the filter's settings.
    static func ResetFilter()
    {
        Settings.SetColor(.ColorMapColor1,
                          Settings.SettingDefaults[.ColorMapColor1] as! UIColor)
        Settings.SetColor(.ColorMapColor2,
                          Settings.SettingDefaults[.ColorMapColor2] as! UIColor)
        Settings.SetString(.ColorMapGradient,
                           Settings.SettingDefaults[.ColorMapGradient] as! String)
    }
}
