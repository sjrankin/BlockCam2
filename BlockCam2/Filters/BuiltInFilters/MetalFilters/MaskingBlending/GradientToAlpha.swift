//
//  GradientToAlpha.swift
//  BlockCam2
//  Adapted from BumpCamera, 3/23/19.
//
//  Created by Stuart Rankin on 4/26/21.
//

import Foundation
import UIKit
import CoreMedia
import CoreVideo
import MetalKit

class GradientToAlpha: MetalFilterParent, BuiltInFilterProtocol
{
    // MARK: - Required by BuiltInFilterProtocol.
    
    static var FilterType: BuiltInFilters = .AlphaBlend
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
    private var BufferPool: CVPixelBufferPool? = nil
    var Initialized = false
    var AccessLock = NSObject()
    var ParameterBuffer: MTLBuffer! = nil
    var PreviousDebug = ""
    
    required override init()
    {
        let DefaultLibrary = MetalDevice?.makeDefaultLibrary()
        let KernelFunction = DefaultLibrary?.makeFunction(name: "GradientToAlpha")
        do
        {
            ComputePipelineState = try MetalDevice?.makeComputePipelineState(function: KernelFunction!)
        }
        catch
        {
            print("Unable to create pipeline state: \(error.localizedDescription)")
        }
    }
    
    func Initialize(With FormatDescription: CMFormatDescription, BufferCountHint: Int)
    {
        Reset()
        (BufferPool, _, OutputFormatDescription) = CreateBufferPool(From: FormatDescription, BufferCountHint: BufferCountHint)
        if BufferPool == nil
        {
            print("BufferPool nil in GradientToAlpha.Initialize.")
            return
        }
        InputFormatDescription = FormatDescription
        
        Initialized = true
        
        var MetalTextureCache: CVMetalTextureCache? = nil
        if CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, MetalDevice!, nil, &MetalTextureCache) != kCVReturnSuccess
        {
            fatalError("Unable to allocation texture cache in GradientToAlpha.")
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
        BufferPool = nil
        OutputFormatDescription = nil
        InputFormatDescription = nil
        TextureCache = nil
        Initialized = false
    }
 
    func Render(PixelBuffer: [CVPixelBuffer], FirstColor: UIColor, SecondColor: UIColor) -> CVPixelBuffer?
    {
        objc_sync_enter(AccessLock)
        defer{objc_sync_exit(AccessLock)}
        
        if !Initialized
        {
            fatalError("GradientToAlpha not initialized at Render(CVPixelBuffer) call.")
        }
        
        //BufferPool is nil - nothing to do (or can do). This probably occurred because the user changed
        //filters out from under us and the video sub-system hadn't quite caught up to the new filter and
        //sent a frame to the no-longer-active filter.
        if BufferPool == nil
        {
            return nil
        }
        
        var NewPixelBuffer: CVPixelBuffer? = nil
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, BufferPool!, &NewPixelBuffer)
        guard let OutputBuffer = NewPixelBuffer else
        {
            print("Allocation failure for new pixel buffer pool in GradientToAlpha.")
            return nil
        }
        
        let GradientDescription = GradientManager.AssembleGradient([(FirstColor, 0.0), (SecondColor, 1.0)])
        let GradientImage = GradientManager.CreateGradientImage(From: GradientDescription,
                                                                WithFrame: CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(PixelBuffer.first!),
                                                                                  height: CVPixelBufferGetHeight(PixelBuffer.first!)),
                                                                IsVertical: true,
                                                                ReverseColors: false)
        let GradientPixelBuffer = GetPixelBufferFrom(GradientImage)
        
        let ResultsCount = 10
        let ResultsBuffer = MetalDevice!.makeBuffer(length: MemoryLayout<ReturnBufferType>.stride * ResultsCount, options: [])
        let Results = UnsafeBufferPointer<ReturnBufferType>(start: UnsafePointer(ResultsBuffer!.contents().assumingMemoryBound(to: ReturnBufferType.self)),
                                                            count: ResultsCount)
        
        guard let InputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: PixelBuffer.first!, TextureFormat: .bgra8Unorm),
              let OutputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: OutputBuffer, TextureFormat: .bgra8Unorm),
              let GradientTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: GradientPixelBuffer!, TextureFormat: .bgra8Unorm) else
        {
            print("Error creating textures in GradientToAlpha.")
            return nil
        }
        
        guard let CommandQ = CommandQueue,
              let CommandBuffer = CommandQ.makeCommandBuffer(),
              let CommandEncoder = CommandBuffer.makeComputeCommandEncoder() else
        {
            print("Error creating Metal command queue.")
            CVMetalTextureCacheFlush(TextureCache!, 0)
            return nil
        }
        
        CommandEncoder.label = "Gradient to Alpha"
        CommandEncoder.setComputePipelineState(ComputePipelineState!)
        CommandEncoder.setTexture(InputTexture, index: 0)
        CommandEncoder.setTexture(GradientTexture, index: 1)
        CommandEncoder.setTexture(OutputTexture, index: 2)
        CommandEncoder.setBuffer(ResultsBuffer, offset: 0, index: 0)
        
        let w = ComputePipelineState!.threadExecutionWidth
        let h = ComputePipelineState!.maxTotalThreadsPerThreadgroup / w
        let ThreadsPerThreadGroup = MTLSize(width: w, height: h, depth: 1)
        let ThreadGroupsPerGrid = MTLSize(width: (InputTexture.width + w - 1) / w,
                                          height: (InputTexture.height + h - 1) / h,
                                          depth: 1)
        CommandEncoder.dispatchThreadgroups(ThreadGroupsPerGrid, threadsPerThreadgroup: ThreadsPerThreadGroup)
        CommandEncoder.endEncoding()
        CommandBuffer.commit()

        return OutputBuffer
    }
  
    func RunFilter(_ Buffer: [CVPixelBuffer], _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace, Options: [FilterOptions: Any]) -> CVPixelBuffer
    {
        return Buffer.first!
    }
}

