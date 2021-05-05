//
//  Crop.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/2/21.
//

import Foundation
import UIKit
import CoreMedia
import CoreVideo
import MetalKit

class Crop: MetalFilterParent, BuiltInFilterProtocol
{
    // MARK: - Required by BuiltInFilterProtocol.
    
    static var FilterType: BuiltInFilters = .Crop
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
        print("Metal kernel function Crop initialized")
        let DefaultLibrary = MetalDevice?.makeDefaultLibrary()
        let KernelFunction = DefaultLibrary?.makeFunction(name: "Crop")
        do
        {
            ComputePipelineState = try MetalDevice?.makeComputePipelineState(function: KernelFunction!)
        }
        catch
        {
            print("Unable to create pipeline state in Crop: \(error.localizedDescription)")
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
            fatalError("LocalBufferPool is nil in Crop.Initialize.")
        }
        InputFormatDescription = FormatDescription
        Initialized = true
        var MetalTextureCache: CVMetalTextureCache? = nil
        guard CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, MetalDevice!, nil, &MetalTextureCache) == kCVReturnSuccess else
        {
            fatalError("Unable to allocate texture cache in Crop.")
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
            fatalError("Crop not initialized.")
        }
        objc_sync_enter(AccessLock)
        defer{objc_sync_exit(AccessLock)}
        
        let TargetWidth = Options[.Width] as? Int ?? 64
        let TargetHeight = Options[.Height] as? Int ?? 64
        let TargetSize = CGSize(width: TargetWidth, height: TargetHeight)
        let CropPoint = Options[.Point] as? CGPoint ?? CGPoint.zero
        
        let Parameter = CropParameters(StartX: simd_int1(CropPoint.x),
                                       StartY: simd_int1(CropPoint.y),
                                       Width: simd_int1(TargetWidth),
                                       Height: simd_int1(TargetHeight))
        let Parameters = [Parameter]
        ParameterBuffer = MetalDevice!.makeBuffer(length: MemoryLayout<CropParameters>.stride,
                                                  options: [])
        memcpy(ParameterBuffer.contents(), Parameters, MemoryLayout<CropParameters>.stride)
        
        var NewPixelBuffer: CVPixelBuffer? = nil
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, LocalBufferPool!, &NewPixelBuffer)
        guard var OutputBuffer = NewPixelBuffer else
        {
            fatalError("Error creating textures for Crop.")
        }
    
        guard let InputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: Buffer.first!, TextureFormat: .bgra8Unorm),
              let OutputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: OutputBuffer, TextureFormat: .bgra8Unorm,
                                                               TextureSize: TargetSize) else
        {
            fatalError("Error creating textures in Crop.")
        }
        
        guard let CommandQ = CommandQueue,
              let CommandBuffer = CommandQ.makeCommandBuffer(),
              let CommandEncoder = CommandBuffer.makeComputeCommandEncoder() else
        {
            fatalError("Error creating Metal command queue in Crop.")
        }
        
        CommandEncoder.label = "Crop Kernel"
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
        
        return OutputBuffer
    }
}
