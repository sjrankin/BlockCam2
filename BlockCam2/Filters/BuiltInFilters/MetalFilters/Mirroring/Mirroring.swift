//
//  Mirroring.swift
//  BlockCam2
//  Adapted from BumpCamera, 2/2/19.
//
//  Created by Stuart Rankin on 4/26/21.
//

import Foundation
import UIKit
import CoreMedia
import CoreVideo
import MetalKit


/// Wrapper for the Mirroring metal kernel.
class MirroringDistortion: MetalFilterParent, BuiltInFilterProtocol
{
    // MARK: - Required by BuiltInFilterProtocol.
    static var FilterType: BuiltInFilters = .Mirroring2
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
    var AccessLock = NSObject()
    var ParameterBuffer: MTLBuffer! = nil

    func Initialize(With FormatDescription: CMFormatDescription, BufferCountHint: Int)
    {
        Reset()
        (LocalBufferPool, _, OutputFormatDescription) = CreateBufferPool(From: FormatDescription,
                                                                         BufferCountHint: BufferCountHint)
        if LocalBufferPool == nil
        {
            fatalError("LocalBufferPool nil in MirrorDistortion.Initialize.")
        }
        InputFormatDescription = FormatDescription
        Initialized = true
        var MetalTextureCache: CVMetalTextureCache? = nil
        if CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, MetalDevice!, nil, &MetalTextureCache) != kCVReturnSuccess
        {
            fatalError("Unable to allocation texture cache in MirrorDistortion.")
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
    
    func Render(PixelBuffer: CVPixelBuffer, _ KernelName: String, SourceIsAV: Bool) -> CVPixelBuffer?
    {
        objc_sync_enter(AccessLock)
        defer{objc_sync_exit(AccessLock)}
        
        let DefaultLibrary = MetalDevice?.makeDefaultLibrary()
        let KernelFunction = DefaultLibrary?.makeFunction(name: KernelName)
        do
        {
            ComputePipelineState = try MetalDevice?.makeComputePipelineState(function: KernelFunction!)
        }
        catch
        {
            fatalError("Unable to create pipeline state: \(error.localizedDescription)")
        }
        
        if !Initialized
        {
            fatalError("MirrorDistortion not initialized at Render(CVPixelBuffer) call.")
        }
        
        //BufferPool is nil - nothing to do (or can do). This probably occurred because the user changed
        //filters out from under us and the video sub-system hadn't quite caught up to the new filter and
        //sent a frame to the no-longer-active filter.
        if LocalBufferPool == nil
        {
            fatalError("LocalBufferPool is nil in Mirroring:\(#function)")
        }
        
        var NewPixelBuffer: CVPixelBuffer? = nil
        #if true
        super.CreateBufferPool(Source: CIImage(cvPixelBuffer: PixelBuffer), From: PixelBuffer)
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, super.BasePool!, &NewPixelBuffer)
        guard let OutputBuffer = NewPixelBuffer else
        {
            Debug.FatalError("Error creating buffer pool for MirrorDistortion.")
        }
        #else
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, LocalBufferPool!, &NewPixelBuffer)
        guard let OutputBuffer = NewPixelBuffer else
        {
            fatalError("Allocation failure for new pixel buffer pool in MirrorDistortion.")
        }
        #endif
        
        guard let InputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: PixelBuffer, TextureFormat: .bgra8Unorm),
              let OutputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: OutputBuffer, TextureFormat: .bgra8Unorm) else
        {
            fatalError("Error creating textures in MirrorDistortion.")
        }
        
        guard let CommandQ = CommandQueue,
              let CommandBuffer = CommandQ.makeCommandBuffer(),
              let CommandEncoder = CommandBuffer.makeComputeCommandEncoder() else
        {
            fatalError("Error creating Metal command queue.")
        }
        
        CommandEncoder.label = "Mirroring Kernel"
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
    
    func RunFilter(_ Buffer: [CVPixelBuffer], _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace, Options: [FilterOptions: Any]) -> CVPixelBuffer
    {
        var KernelName = ""
        switch Settings.GetInt(.MirrorDirection)
        {
            case 0:
                if Settings.GetBool(.MirrorLeft)
                {
                    KernelName = "MirrorHorizontalLeftToRight"
                }
                else
                {
                    KernelName = "MirrorHorizontalRightToLeft"
                }
                
            case 1:
                if Settings.GetBool(.MirrorTop)
                {
                    KernelName = "MirrorVerticalTopToBottom"
                }
                else
                {
                    KernelName = "MirrorVerticalBottomToTop"
                }
                
            case 2:
                if Settings.GetInt(.MirrorQuadrant) > 0
                {
                    let Quadrant = Settings.GetInt(.MirrorQuadrant)
                    KernelName = "MirrorQuadrant\(Quadrant)"
                    //KernelName = "MirrorQuadrant2"
                    print("KernelName=\(KernelName)")
                }
                else
                {
                    Settings.SetInt(.MirrorQuadrant, 1)
                }
                
            default:
                fatalError("Unexpected mirroring direction (\(Settings.GetInt(.MirrorDirection)) encountered.")
        }
        if let Rendered = Render(PixelBuffer: Buffer.first!, KernelName, SourceIsAV: Options[.SourceIsAV] as? Bool ?? false)
        {
            return Rendered
        }
        fatalError("Error returned by Mirroring.Render with kernel \(KernelName)")
    }
    
    /// Reset the filter's settings.
    static func ResetFilter()
    {
    }
}
