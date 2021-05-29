//
//  MultiFrameCombiners.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/27/21.
//

import Foundation
import UIKit
import CoreMedia
import CoreVideo
import MetalKit

class MultiFrameCombiner: MetalFilterParent, BuiltInFilterProtocol
{
    // MARK: - Required by BuiltInFilterProtocol.
    
    static var FilterType: BuiltInFilters = .MultiFrameCombiner
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
    
    private var BufferPool: CVPixelBufferPool? = nil
    
    func Initialize(With FormatDescription: CMFormatDescription, BufferCountHint: Int)
    {
        if Initialized
        {
            return
        }
        
        Reset()
        (BufferPool, _, OutputFormatDescription) = CreateBufferPool(From: FormatDescription, BufferCountHint: BufferCountHint)
        if BufferPool == nil
        {
            Debug.FatalError("BufferPool nil in MultiFrameCombiners.Initialize.")
        }
        InputFormatDescription = FormatDescription
        
        Initialized = true
        
        var MetalTextureCache: CVMetalTextureCache? = nil
        if CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, MetalDevice!, nil, &MetalTextureCache) != kCVReturnSuccess
        {
            Debug.FatalError("Unable to allocation texture cache in MultiFrameCombiners.")
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
    
    var AccessLock = NSObject()
    
    func RunFilter(_ Buffer: [CVPixelBuffer], _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace, Options: [FilterOptions: Any]) -> CVPixelBuffer
    {
        objc_sync_enter(AccessLock)
        defer{objc_sync_exit(AccessLock)}
        
        if !Initialized
        {
            Debug.FatalError("MultiFrameCombiner not initialized at Render(CVPixelBuffer) call.")
        }
        if Buffer.count != 2
        {
            Debug.FatalError("Incorrect number of buffers in MultiFrameCombiners.RunFilter. Found \(Buffer.count); expected 2.")
        }
        
        let Invert = Options[.Invert] as? Bool ?? false
        let Comparison = Options[.IntCommand] as? Int ?? 0
        print("MultiFrameCombiners: Invert=\(Invert), Comparison=\(Comparison)")
        
        var KernelName = ""
        switch Comparison
        {
            case 0:
                KernelName = "MultiFrameCombiner2Bright"
                
            case 1:
                KernelName = "MultiFrameCombiner2Red"
                
            case 2:
                KernelName = "MultiFrameCombiner2Green"
                
            case 3:
                KernelName = "MultiFrameCombiner2Blue"
                
            case 4:
                KernelName = "MultiFrameCombiner2Cyan"
                
            case 5:
                KernelName = "MultiFrameCombiner2Magenta"
                
            case 6:
                KernelName = "MultiFrameCombiner2Yellow"
                
            default:
                Debug.FatalError("Unexpected companison command (\(Comparison)) encountered.")
        }
       
        print("MultiFrameCombiners: Kernel=\(KernelName)")
        
        var Buffers = Buffer
        if Invert
        {
            Buffers.swapAt(0, 1)
        }
        
        let DefaultLibrary = MetalDevice?.makeDefaultLibrary()
        let KernelFunction = DefaultLibrary?.makeFunction(name: KernelName)
        do
        {
            ComputePipelineState = try MetalDevice?.makeComputePipelineState(function: KernelFunction!)
        }
        catch
        {
            Debug.FatalError("Unable to create pipeline state: \(error.localizedDescription)")
        }

        let Parameter = MultiFrameParameters(InvertComparison: simd_bool(Invert), Comparison: simd_uint1(Comparison))
        let Parameters = [Parameter]
        ParameterBuffer = MetalDevice!.makeBuffer(length: MemoryLayout<MultiFrameParameters>.stride, options: [])
        memcpy(ParameterBuffer.contents(), Parameters, MemoryLayout<MultiFrameParameters>.stride)
        
        super.CreateBufferPool(Source: CIImage(cvPixelBuffer: Buffers.first!), From: Buffers.first!)
        var NewPixelBuffer: CVPixelBuffer? = nil
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, super.BasePool!, &NewPixelBuffer)
        guard let OutputBuffer = NewPixelBuffer else
        {
            Debug.FatalError("Error creation textures for MultiFrameCombiner.")
        }
        
        guard let InputTexture0 = MakeTextureFromCVPixelBuffer(PixelBuffer: Buffers[0], TextureFormat: .bgra8Unorm) else
        {
            Debug.FatalError("Error creating input texture 0 in MultiFrameCombiner.")
        }
        guard let InputTexture1 = MakeTextureFromCVPixelBuffer(PixelBuffer: Buffers[1], TextureFormat: .bgra8Unorm) else
        {
            Debug.FatalError("Error creating input texture 1 in MultiFrameCombiner.")
        }
        guard let OutputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: OutputBuffer, TextureFormat: .bgra8Unorm) else
        {
            Debug.FatalError("Error creating output texture in MultiFrameCombiner.")
        }
        
        guard let CommandQ = CommandQueue,
              let CommandBuffer = CommandQ.makeCommandBuffer(),
              let CommandEncoder = CommandBuffer.makeComputeCommandEncoder() else
        {
            Debug.FatalError("Error creating Metal command queue.")
        }
        
        CommandEncoder.label = "Multi Frame Combiner Kernel"
        CommandEncoder.setComputePipelineState(ComputePipelineState!)
        CommandEncoder.setTexture(InputTexture0, index: 0)
        CommandEncoder.setTexture(InputTexture1, index: 1)
        CommandEncoder.setTexture(OutputTexture, index: 2)
        CommandEncoder.setBuffer(ParameterBuffer, offset: 0, index: 0)
        
        let w = ComputePipelineState!.threadExecutionWidth
        let h = ComputePipelineState!.maxTotalThreadsPerThreadgroup / w
        let ThreadsPerThreadGroup = MTLSize(width: w, height: h, depth: 1)
        let ThreadGroupsPerGrid = MTLSize(width: (InputTexture0.width + w - 1) / w,
                                          height: (InputTexture0.height + h - 1) / h,
                                          depth: 1)
        CommandEncoder.dispatchThreadgroups(ThreadGroupsPerGrid, threadsPerThreadgroup: ThreadsPerThreadGroup)
        CommandEncoder.endEncoding()
        CommandBuffer.commit()
        CommandBuffer.waitUntilCompleted()
        
        return OutputBuffer
    }
    
    static func ResetFilter()
    {
        Settings.SetInt(.MultiFrameCombinerCommand,
                        Settings.SettingDefaults[.MultiFrameCombinerCommand] as! Int)
        Settings.SetBool(.MultiFrameCombinerInvertCommand,
                         Settings.SettingDefaults[.MultiFrameCombinerInvertCommand] as! Bool)
    }
}
