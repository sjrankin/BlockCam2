//
//  Reflect.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/2/21.
//

import Foundation
import UIKit
import CoreMedia
import CoreVideo
import MetalKit

class Reflect: MetalFilterParent, BuiltInFilterProtocol
{
    // MARK: - Required by BuiltInFilterProtocol.
    
    static var FilterType: BuiltInFilters = .Reflect
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
            fatalError("LocalBufferPool is nil in Reflect.Initialize.")
        }
        InputFormatDescription = FormatDescription
        Initialized = true
        var MetalTextureCache: CVMetalTextureCache? = nil
        guard CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, MetalDevice!, nil, &MetalTextureCache) == kCVReturnSuccess else
        {
            fatalError("Unable to allocate texture cache in Reflect.")
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
            fatalError("Reflect not initialized.")
        }
        objc_sync_enter(AccessLock)
        defer{objc_sync_exit(AccessLock)}
        
        let FilterName = Options[.FilterName] as? String ?? "HorizontalReflect"
        let DefaultLibrary = MetalDevice?.makeDefaultLibrary()
        let KernelFunction = DefaultLibrary?.makeFunction(name: FilterName)
        do
        {
            ComputePipelineState = try MetalDevice?.makeComputePipelineState(function: KernelFunction!)
        }
        catch
        {
            fatalError("Unable to create pipeline state in Reflect: \(error.localizedDescription)")
        }
        
        var NewPixelBuffer: CVPixelBuffer? = nil
        #if true
        super.CreateBufferPool(Source: CIImage(cvPixelBuffer: Buffer.first!), From: Buffer.first!)
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, super.BasePool!, &NewPixelBuffer)
        guard let OutputBuffer = NewPixelBuffer else
        {
            Debug.FatalError("Error creating buffer pool for Reflect.")
        }
        #else
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, LocalBufferPool!, &NewPixelBuffer)
        guard var OutputBuffer = NewPixelBuffer else
        {
            fatalError("Error creating textures for Reflect.")
        }
        #endif
        
        guard let InputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: Buffer.first!, TextureFormat: .bgra8Unorm) else
        {
            fatalError("Error creating input texture in Reflect.")
        }
        guard let OutputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: OutputBuffer, TextureFormat: .bgra8Unorm) else
        {
            fatalError("Error creating output texture in Reflect.")
        }
        
        guard let CommandQ = CommandQueue,
              let CommandBuffer = CommandQ.makeCommandBuffer(),
              let CommandEncoder = CommandBuffer.makeComputeCommandEncoder() else
        {
            fatalError("Error creating Metal command queue.")
        }
        
        CommandEncoder.label = FilterName
        CommandEncoder.setComputePipelineState(ComputePipelineState!)
        CommandEncoder.setTexture(InputTexture, index: 0)
        CommandEncoder.setTexture(OutputTexture, index: 1)
        
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
