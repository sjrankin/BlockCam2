//
//  Threshold.swift
//  BlockCam2
//  Adapted from BumpCamera, 2/6/19.
//
//  Created by Stuart Rankin on 4/26/21.
//

import Foundation
import UIKit
import CoreMedia
import CoreVideo
import MetalKit

class ThresholdOld: MetalFilterParent, BuiltInFilterProtocol
{
    static var FilterType: BuiltInFilters = .Threshold
    var NeedsInitialization: Bool = true
    
    required override init()
    {
        let DefaultLibrary = MetalDevice?.makeDefaultLibrary()
        let KernelFunction = DefaultLibrary?.makeFunction(name: "ThresholdKernel")
        do
        {
            ComputePipelineState = try MetalDevice?.makeComputePipelineState(function: KernelFunction!)
        }
        catch
        {
            print("Unable to create pipeline state: \(error.localizedDescription)")
        }
    }
    
    var AccessLock = NSObject()
    var ParameterBuffer: MTLBuffer! = nil
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
    
    func Initialize(With FormatDescription: CMFormatDescription, BufferCountHint: Int)
    {
        Reset()
        (LocalBufferPool, _, OutputFormatDescription) = CreateBufferPool(From: FormatDescription, BufferCountHint: BufferCountHint)
        if LocalBufferPool == nil
        {
            print("BufferPool nil in Threshold.")
            return
        }
        InputFormatDescription = FormatDescription
        
        Initialized = true
        
        var MetalTextureCache: CVMetalTextureCache? = nil
        if CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, MetalDevice!, nil, &MetalTextureCache) != kCVReturnSuccess
        {
            fatalError("Unable to allocation texture cache in type(of: self).")
        }
        else
        {
            TextureCache = MetalTextureCache
        }
    }
    
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
    
    func RunFilter(_ PixelBuffer: [CVPixelBuffer], _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace, Options: [FilterOptions : Any]) -> CVPixelBuffer
    {
        if PixelBuffer.isEmpty
        {
            Debug.FatalError("PixelBuffer array is empty in Threshold.")
        }
        guard let Buffer = PixelBuffer.first else
        {
            Debug.FatalError("Pixel buffer is nil in Threshold.")
        }
        objc_sync_enter(AccessLock)
        defer{objc_sync_exit(AccessLock)}
        if !Initialized
        {
            Debug.FatalError("Threshold not initialized.")
        }

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
        
        var NewPixelBuffer: CVPixelBuffer? = nil
        super.CreateBufferPool(Source: CIImage(cvPixelBuffer: Buffer), From: Buffer)
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, super.BasePool!, &NewPixelBuffer)
        guard let OutputBuffer = NewPixelBuffer else
        {
            Debug.FatalError("Error creating buffer pool for Threshold.")
        }
        
        guard let OutputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: OutputBuffer,
                                                               TextureFormat: .bgra8Unorm) else
        {
            Debug.FatalError("Error creating output texture in Threshold.")
        }
        guard let InputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: Buffer,
                                                              TextureFormat: .bgra8Unorm) else
        {
            Debug.FatalError("Error creating input texture in Threshold.")
        }
        
        guard let CommandQ = CommandQueue,
              let CommandBuffer = CommandQ.makeCommandBuffer(),
              let CommandEncoder = CommandBuffer.makeComputeCommandEncoder() else
        {
            print("Error creating Metal command queue.")
            CVMetalTextureCacheFlush(TextureCache!, 0)
            return PixelBuffer.first!
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

        return OutputBuffer
    }
    
    /// Reset the filter's settings.
    static func ResetFilter()
    {
    }
}
