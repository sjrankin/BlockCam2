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
    static var FilterType: BuiltInFilters = .Mirroring
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
    
    required override init()
    {
        let DefaultLibrary = MetalDevice?.makeDefaultLibrary()
        let KernelFunction = DefaultLibrary?.makeFunction(name: "MirroringKernel")
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
        (LocalBufferPool, _, OutputFormatDescription) = CreateBufferPool(From: FormatDescription, BufferCountHint: BufferCountHint)
        if LocalBufferPool == nil
        {
            print("LocalBufferPool nil in MirrorDistortion.Initialize.")
            return
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
    
    func Render(PixelBuffer: CVPixelBuffer, SourceIsAV: Bool) -> CVPixelBuffer?
    {
        objc_sync_enter(AccessLock)
        defer{objc_sync_exit(AccessLock)}
        
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
 
        var MDirection = SourceIsAV ? 1 : 0
        //Because AV-based images seem to be rotated either 90 or 270 degrees, we need to changed
        //the direction orientation if necessary.
        MDirection = [0: 1, 1: 0, 2: 2, 3: 4, 4: 3][MDirection]!
        let HSide = 1 - 0
        let VSide = 1 - 0
        var Quadrant = 1
        //Because AV-based images are rotated right, we need to rotate the quadrant number for quandrant reflections...
        Quadrant = [2: 1, 3: 2, 4: 3, 1: 4][Quadrant]!
        
        let Parameter = MirrorParameters(Direction: simd_uint1(MDirection),
                                         HorizontalSide: simd_uint1(HSide),
                                         VerticalSide: simd_uint1(VSide),
                                         Quadrant: simd_uint1(Quadrant),
                                         IsAVRotated: simd_bool(true))
        let Parameters = [Parameter]
        ParameterBuffer = MetalDevice!.makeBuffer(length: MemoryLayout<MirrorParameters>.stride, options: [])
        memcpy(ParameterBuffer.contents(), Parameters, MemoryLayout<MirrorParameters>.stride)
        
        let ResultCount = 10
        let ResultsBuffer = MetalDevice!.makeBuffer(length: MemoryLayout<ReturnBufferType>.stride * ResultCount, options: [])
        let Results = UnsafeBufferPointer<ReturnBufferType>(start: UnsafePointer(ResultsBuffer!.contents().assumingMemoryBound(to: ReturnBufferType.self)),
                                                            count: ResultCount)
        
        var NewPixelBuffer: CVPixelBuffer? = nil
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, LocalBufferPool!, &NewPixelBuffer)
        guard let OutputBuffer = NewPixelBuffer else
        {
            fatalError("Allocation failure for new pixel buffer pool in MirrorDistortion.")
        }
        
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
        
        CommandEncoder.setBuffer(ResultsBuffer, offset: 0, index: 1)
        
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
        
        #if false
        for V in Results
        {
            if V > 0
            {
                print("V=\(V)")
            }
        }
        #endif

        return OutputBuffer
    }
    
    /// Run the mirroring filter.
    /// - Warning: Fatal errors are thrown on internal errors.
    /// - Notes: The following options are valid:
    ///   - `HorizontalMirrorSide`: Determines which horizontal side to mirror.
    ///   - `VerticalMirrorSide`: Determines which vertical side to mirror.
    ///   - `MirrorQuadrant`: Determines which quadrant to mirror.
    ///   - `SourceIsAV`: Caller should set this to true if the image source is from `AVFoundation`.
    /// - Parameter Buffer: The source image buffer to mirror.
    /// - Parameter BufferPool: Not used.
    /// - Parameter ColorSpace: Not used.
    /// - Parameter Options: Options for mirroring. See notes.
    /// - Returns: Modified pixel buffer.
    func RunFilter(_ Buffer: CVPixelBuffer, _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace, Options: [FilterOptions: Any]) -> CVPixelBuffer
    {
        if let Rendered = Render(PixelBuffer: Buffer, SourceIsAV: Options[.SourceIsAV] as? Bool ?? false)
        {
            return Rendered
        }
        fatalError("Error returned by Mirroring.Render")
    }
}
