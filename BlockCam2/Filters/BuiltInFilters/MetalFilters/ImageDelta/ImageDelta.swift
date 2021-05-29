//
//  ImageDelta.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/28/21.
//

import Foundation
import UIKit
import CoreMedia
import CoreVideo
import MetalKit

class ImageDelta: MetalFilterParent, BuiltInFilterProtocol
{
    // MARK: - Required by BuiltInFilterProtocol.
    
    static var FilterType: BuiltInFilters = .ImageDelta
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
    
    /*
    override required init()
    {
        print("Metal kernel function ImageDelta initialized")
        let DefaultLibrary = MetalDevice?.makeDefaultLibrary()
        let KernelFunction = DefaultLibrary?.makeFunction(name: "ImageDelta")
        do
        {
            ComputePipelineState = try MetalDevice?.makeComputePipelineState(function: KernelFunction!)
        }
        catch
        {
            print("Unable to create pipeline state in ImageDelta: \(error.localizedDescription)")
        }
    }
 */
    
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
            print("LocalBufferPool is nil in ImageDelta.Initialize.")
            return
        }
        InputFormatDescription = FormatDescription
        Initialized = true
        var MetalTextureCache: CVMetalTextureCache? = nil
        guard CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, MetalDevice!, nil, &MetalTextureCache) == kCVReturnSuccess else
        {
            fatalError("Unable to allocate texture cache in ImageDelta.")
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
            Debug.FatalError("ImageDelta not initialized.")
        }
        
        if Buffer.count != 2
        {
            Debug.FatalError("Incorrect number of buffers in ImageDelta.RunFilter. Found \(Buffer.count); expected 2.")
        }
        
        objc_sync_enter(AccessLock)
        defer{objc_sync_exit(AccessLock)}
        
        let Command = Options[.IntCommand] as! Int
        let Threshold = Options[.Threshold] as! Double
        let UseEffective = Options[.UseEffective] as! Bool
        let EffectiveColor = Options[.EffectiveColor] as! UIColor
        let BGColor = Options[.BGColor] as! UIColor
        
        let KernelName = ["ImageAbsoluteDelta", "ImageOnlyDelta", "ImageOnlySame", "ImageDelta", "ImageDeltaFromPrimary"][Command]
        print("ImageDelta kernel=\(KernelName)")
        
        let DefaultLibrary = MetalDevice?.makeDefaultLibrary()
        let KernelFunction = DefaultLibrary?.makeFunction(name: KernelName)
        do
        {
            ComputePipelineState = try MetalDevice?.makeComputePipelineState(function: KernelFunction!)
        }
        catch
        {
            Debug.FatalError("Unable to create pipeline state in ImageDelta[\(KernelName)]: \(error.localizedDescription)")
        }
        
        let Parameter = ImageDeltaParameters(BackgroundColor: BGColor.ToFloat4(),
                                             Operation: simd_uint1(Command),
                                             Threshold: simd_float1(Threshold),
                                             UseEffectiveColor: simd_bool(UseEffective),
                                             EffectiveColor: EffectiveColor.ToFloat4())
        let Parameters = [Parameter]
        ParameterBuffer = MetalDevice!.makeBuffer(length: MemoryLayout<ImageDeltaParameters>.stride,
                                                  options: [])
        memcpy(ParameterBuffer.contents(), Parameters, MemoryLayout<ImageDeltaParameters>.stride)
        
        var NewPixelBuffer: CVPixelBuffer? = nil
        
        super.CreateBufferPool(Source: CIImage(cvPixelBuffer: Buffer.first!), From: Buffer.first!)
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, super.BasePool!, &NewPixelBuffer)
        guard let OutputBuffer = NewPixelBuffer else
        {
            Debug.FatalError("Error allocating output texture for ImageDelta.")
        }
        
        guard let OutputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: OutputBuffer, TextureFormat: .bgra8Unorm) else
        {
            Debug.FatalError("Error creating output texture in ImageDelta.")
        }
        guard let InputTexture0 = MakeTextureFromCVPixelBuffer(PixelBuffer: Buffer[0], TextureFormat: .bgra8Unorm) else
        {
            Debug.FatalError("Error creating input texture 0 in ImageDelta.")
        }
        guard let InputTexture1 = MakeTextureFromCVPixelBuffer(PixelBuffer: Buffer[1], TextureFormat: .bgra8Unorm) else
        {
            Debug.FatalError("Error creating input texture 1 in ImageDelta.")
        }
        
        guard let CommandQ = CommandQueue,
              let CommandBuffer = CommandQ.makeCommandBuffer(),
              let CommandEncoder = CommandBuffer.makeComputeCommandEncoder() else
        {
            Debug.FatalError("Error creating Metal command queue.")
        }
        
        CommandEncoder.label = "ImageDelta Map Kernel"
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
    
    /// Reset the filter's settings.
    static func ResetFilter()
    {
    }
}
