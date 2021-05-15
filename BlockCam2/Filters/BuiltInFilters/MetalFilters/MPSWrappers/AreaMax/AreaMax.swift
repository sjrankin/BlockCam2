//
//  AreaMax.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/14/21.
//

import Foundation
import UIKit
import CoreMedia
import CoreVideo
import MetalKit
import MetalPerformanceShaders

class MPSAreaMax: MetalFilterParent, BuiltInFilterProtocol
{
    static var FilterType: BuiltInFilters = .Laplacian
    var NeedsInitialization: Bool = true
    
    required override init()
    {
        super.init()
    }
    
    private let MetalDevice = MTLCreateSystemDefaultDevice()
    private lazy var CommandQueue: MTLCommandQueue? =
        {
            return self.MetalDevice?.makeCommandQueue()
        }()
    private(set) var OutputFormatDescription: CMFormatDescription? = nil
    private(set) var InputFormatDescription: CMFormatDescription? = nil
    var Initialized = false
    var bciContext: CIContext!
    var ciContext: CIContext!
    private var LocalBufferPool: CVPixelBufferPool? = nil
    var AccessLock = NSObject()
    
    func Initialize(With FormatDescription: CMFormatDescription, BufferCountHint: Int)
    {
        Reset()
        (LocalBufferPool, _, OutputFormatDescription) = CreateBufferPool(From: FormatDescription, BufferCountHint: BufferCountHint)
        if LocalBufferPool == nil
        {
            print("BufferPool nil in AreaMax.Initialize.")
            return
        }
        InputFormatDescription = FormatDescription
        CommandQueue = MetalDevice?.makeCommandQueue()
        bciContext = CIContext()
        Initialized = true
        var MetalTextureCache: CVMetalTextureCache? = nil
        if CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, MetalDevice!, nil, &MetalTextureCache) != kCVReturnSuccess
        {
            fatalError("Unable to allocation texture cache in AreaMax.")
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
        OutputFormatDescription = nil
        InputFormatDescription = nil
        TextureCache = nil
        ciContext = nil
        bciContext = nil
        CommandQueue = nil
        Initialized = false
    }
    
    func RunFilter(_ PixelBuffer: [CVPixelBuffer], _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace, Options: [FilterOptions : Any]) -> CVPixelBuffer
    {
        objc_sync_enter(AccessLock)
        defer{objc_sync_exit(AccessLock)}
        
        if !Initialized
        {
            fatalError("AreaMax not initialized.")
        }
        
        var NewPixelBuffer: CVPixelBuffer? = nil
        #if true
        super.CreateBufferPool(Source: CIImage(cvPixelBuffer: PixelBuffer.first!), From: PixelBuffer.first!)
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, super.BasePool!, &NewPixelBuffer)
        guard let OutputBuffer = NewPixelBuffer else
        {
            Debug.FatalError("Error creating buffer pool for AreaMax.")
        }
        #else
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, LocalBufferPool!, &NewPixelBuffer)
        guard let OutputBuffer = NewPixelBuffer else
        {
            print("Allocation failure for new pixel buffer pool in AreaMax.")
            return PixelBuffer.first!
        }
        #endif
        
        guard let InputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: PixelBuffer.first!,
                                                              TextureFormat: .bgra8Unorm) else
        {
            print("Error creating input texture in AreaMax.")
            return PixelBuffer.first!
        }
        guard let OutputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: OutputBuffer,
                                                               TextureFormat: .bgra8Unorm) else
        {
            print("Error creating output texture in AreaMax.")
            return PixelBuffer.first!
        }
        
        guard let CommandQ = CommandQueue,
              let CommandBuffer = CommandQ.makeCommandBuffer() else
        {
            print("Error creating Metal command queue in AreaMax.")
            CVMetalTextureCacheFlush(TextureCache!, 0)
            return PixelBuffer.first!
        }
        
        let Width = Int(Options[.Width] as? Int ?? 16)
        let Height = Int(Options[.Height] as? Int ?? 16)
        let Shader = MPSImageAreaMax(device: MetalDevice!, kernelWidth: Width, kernelHeight: Height)
        Shader.encode(commandBuffer: CommandBuffer, sourceTexture: InputTexture, destinationTexture: OutputTexture)
        CommandBuffer.commit()
        CommandBuffer.waitUntilCompleted()
        
        return OutputBuffer
    }
    
    /// Reset the filter's settings.
    static func ResetFilter()
    {
    }
}
