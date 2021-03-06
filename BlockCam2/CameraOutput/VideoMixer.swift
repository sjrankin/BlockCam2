//
//  VideoMixer.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/18/21.
//

import Foundation
import CoreMedia
import CoreVideo

class VideoMixer
{
    func allocateOutputBufferPool(with inputFormatDescription: CMFormatDescription,
                                  outputRetainedBufferCountHint: Int) ->(
                                    outputBufferPool: CVPixelBufferPool?,
                                    outputColorSpace: CGColorSpace?,
                                    outputFormatDescription: CMFormatDescription?)
    {
        
        let inputMediaSubType = CMFormatDescriptionGetMediaSubType(inputFormatDescription)
        if inputMediaSubType != kCVPixelFormatType_32BGRA {
            assertionFailure("Invalid input pixel buffer type \(inputMediaSubType)")
            return (nil, nil, nil)
        }
        
        let inputDimensions = CMVideoFormatDescriptionGetDimensions(inputFormatDescription)
        var pixelBufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: UInt(inputMediaSubType),
            kCVPixelBufferWidthKey as String: Int(inputDimensions.width),
            kCVPixelBufferHeightKey as String: Int(inputDimensions.height),
            kCVPixelBufferIOSurfacePropertiesKey as String: [:]
        ]
        
        // Get pixel buffer attributes and color space from the input format description
        var cgColorSpace = CGColorSpaceCreateDeviceRGB()
        if let inputFormatDescriptionExtension = CMFormatDescriptionGetExtensions(inputFormatDescription) as Dictionary?
        {
            let colorPrimaries = inputFormatDescriptionExtension[kCVImageBufferColorPrimariesKey]
            
            if let colorPrimaries = colorPrimaries {
                var colorSpaceProperties: [String: AnyObject] = [kCVImageBufferColorPrimariesKey as String: colorPrimaries]
                
                if let yCbCrMatrix = inputFormatDescriptionExtension[kCVImageBufferYCbCrMatrixKey]
                {
                    colorSpaceProperties[kCVImageBufferYCbCrMatrixKey as String] = yCbCrMatrix
                }
                
                if let transferFunction = inputFormatDescriptionExtension[kCVImageBufferTransferFunctionKey]
                {
                    colorSpaceProperties[kCVImageBufferTransferFunctionKey as String] = transferFunction
                }
                
                pixelBufferAttributes[kCVBufferPropagatedAttachmentsKey as String] = colorSpaceProperties
            }
            
            if let cvColorspace = inputFormatDescriptionExtension[kCVImageBufferCGColorSpaceKey]
            {
                cgColorSpace = cvColorspace as! CGColorSpace
            } else if (colorPrimaries as? String) == (kCVImageBufferColorPrimaries_P3_D65 as String)
            {
                cgColorSpace = CGColorSpace(name: CGColorSpace.displayP3)!
            }
        }
        
        // Create a pixel buffer pool with the same pixel attributes as the input format description
        let poolAttributes = [kCVPixelBufferPoolMinimumBufferCountKey as String: outputRetainedBufferCountHint]
        var cvPixelBufferPool: CVPixelBufferPool?
        CVPixelBufferPoolCreate(kCFAllocatorDefault, poolAttributes as NSDictionary?, pixelBufferAttributes as NSDictionary?, &cvPixelBufferPool)
        guard let pixelBufferPool = cvPixelBufferPool else
        {
            assertionFailure("Allocation failure: Could not allocate pixel buffer pool")
            return (nil, nil, nil)
        }
        
        preallocateBuffers(pool: pixelBufferPool, allocationThreshold: outputRetainedBufferCountHint)
        
        // Get output format description
        var pixelBuffer: CVPixelBuffer?
        var outputFormatDescription: CMFormatDescription?
        let auxAttributes = [kCVPixelBufferPoolAllocationThresholdKey as String: outputRetainedBufferCountHint] as NSDictionary
        CVPixelBufferPoolCreatePixelBufferWithAuxAttributes(kCFAllocatorDefault, pixelBufferPool, auxAttributes, &pixelBuffer)
        if let pixelBuffer = pixelBuffer
        {
            CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: pixelBuffer, formatDescriptionOut: &outputFormatDescription)
        }
        pixelBuffer = nil
        
        return (pixelBufferPool, cgColorSpace, outputFormatDescription)
    }
    
    private func preallocateBuffers(pool: CVPixelBufferPool, allocationThreshold: Int)
    {
        var pixelBuffers = [CVPixelBuffer]()
        var error: CVReturn = kCVReturnSuccess
        let auxAttributes = [kCVPixelBufferPoolAllocationThresholdKey as String: allocationThreshold] as NSDictionary
        var pixelBuffer: CVPixelBuffer?
        while error == kCVReturnSuccess
        {
            error = CVPixelBufferPoolCreatePixelBufferWithAuxAttributes(kCFAllocatorDefault, pool, auxAttributes, &pixelBuffer)
            if let pixelBuffer = pixelBuffer
            {
                pixelBuffers.append(pixelBuffer)
            }
            pixelBuffer = nil
        }
        pixelBuffers.removeAll()
    }
    
    
    var description: String = "Video Mixer"
    
    var isPrepared = false
    
    private(set) var inputFormatDescription: CMFormatDescription?
    
    private(set) var outputFormatDescription: CMFormatDescription?
    
    private var outputPixelBufferPool: CVPixelBufferPool?
    
    private let metalDevice = MTLCreateSystemDefaultDevice()!
    
    private var renderPipelineState: MTLRenderPipelineState?
    
    private var sampler: MTLSamplerState?
    
    private var textureCache: CVMetalTextureCache!
    
    private lazy var commandQueue: MTLCommandQueue? =
        {
            return self.metalDevice.makeCommandQueue()
        }()
    
    private var fullRangeVertexBuffer: MTLBuffer?
    
    var mixFactor: Float = 0.5
    
    init()
    {
        let vertexData: [Float] = [
            -1.0, 1.0,
            1.0, 1.0,
            -1.0, -1.0,
            1.0, -1.0
        ]
        
        fullRangeVertexBuffer = metalDevice.makeBuffer(bytes: vertexData, length: vertexData.count * MemoryLayout<Float>.size, options: [])
        
        let defaultLibrary = metalDevice.makeDefaultLibrary()!
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.vertexFunction = defaultLibrary.makeFunction(name: "vertexMixer")
        pipelineDescriptor.fragmentFunction = defaultLibrary.makeFunction(name: "fragmentMixer")
        
        do
        {
            renderPipelineState = try metalDevice.makeRenderPipelineState(descriptor: pipelineDescriptor)
        }
        catch
        {
            fatalError("Unable to create video mixer pipeline state. (\(error))")
        }
        
        // To determine how our textures are sampled, we create a sampler descriptor, which
        // is used to ask for a sampler state object from our device.
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        sampler = metalDevice.makeSamplerState(descriptor: samplerDescriptor)
    }
    
    func prepare(with videoFormatDescription: CMFormatDescription, outputRetainedBufferCountHint: Int)
    {
        reset()
        
        (outputPixelBufferPool, _, outputFormatDescription) = allocateOutputBufferPool(with: videoFormatDescription,
                                                                                       outputRetainedBufferCountHint: outputRetainedBufferCountHint)
        if outputPixelBufferPool == nil
        {
            return
        }
        inputFormatDescription = videoFormatDescription
        
        var metalTextureCache: CVMetalTextureCache?
        if CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, metalDevice, nil, &metalTextureCache) != kCVReturnSuccess
        {
            assertionFailure("Unable to allocate video mixer texture cache")
        }
        else
        {
            textureCache = metalTextureCache
        }
        
        isPrepared = true
    }
    
    func reset()
    {
        outputPixelBufferPool = nil
        outputFormatDescription = nil
        inputFormatDescription = nil
        textureCache = nil
        isPrepared = false
    }
    
    struct MixerParameters
    {
        var mixFactor: Float
    }
    
    func mix(videoPixelBuffer: CVPixelBuffer, depthPixelBuffer: CVPixelBuffer) -> CVPixelBuffer?
    {
        if !isPrepared {
            assertionFailure("Invalid state: Not prepared")
            return nil
        }
        
        var newPixelBuffer: CVPixelBuffer?
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, outputPixelBufferPool!, &newPixelBuffer)
        guard let outputPixelBuffer = newPixelBuffer else
        {
            print("Allocation failure: Could not get pixel buffer from pool (\(self.description))")
            return nil
        }
        guard let outputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: outputPixelBuffer),
              let inputTexture0 = MakeTextureFromCVPixelBuffer(PixelBuffer: videoPixelBuffer),
              let inputTexture1 = MakeTextureFromCVPixelBuffer(PixelBuffer: depthPixelBuffer) else
        {
            return nil
        }
        
        var parameters = MixerParameters(mixFactor: mixFactor)
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = outputTexture
        
        guard let fullRangeVertexBuffer = fullRangeVertexBuffer else
        {
            print("Failed to create Metal vertex buffer")
            CVMetalTextureCacheFlush(textureCache!, 0)
            return nil
        }
        
        guard let sampler = sampler else
        {
            print("Failed to create Metal sampler")
            CVMetalTextureCacheFlush(textureCache!, 0)
            return nil
        }
        
        // Set up command queue, buffer, and encoder
        guard let commandQueue = commandQueue,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else
        {
            print("Failed to create Metal command queue")
            CVMetalTextureCacheFlush(textureCache!, 0)
            return nil
        }
        
        commandEncoder.label = "Video Mixer"
        commandEncoder.setRenderPipelineState(renderPipelineState!)
        commandEncoder.setVertexBuffer(fullRangeVertexBuffer, offset: 0, index: 0)
        commandEncoder.setFragmentTexture(inputTexture0, index: 0)
        commandEncoder.setFragmentTexture(inputTexture1, index: 1)
        commandEncoder.setFragmentSamplerState(sampler, index: 0)
        commandEncoder.setFragmentBytes( UnsafeMutableRawPointer(&parameters), length: MemoryLayout<MixerParameters>.size, index: 0)
        commandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        commandEncoder.endEncoding()
        
        commandBuffer.commit()
        
        return outputPixelBuffer
    }
    
    func MakeTextureFromCVPixelBuffer(PixelBuffer: CVPixelBuffer) -> MTLTexture?
    {
        let width = CVPixelBufferGetWidth(PixelBuffer)
        let height = CVPixelBufferGetHeight(PixelBuffer)
        
        // Create a Metal texture from the image buffer
        var cvTextureOut: CVMetalTexture?
        CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, PixelBuffer, nil, .bgra8Unorm, width, height, 0, &cvTextureOut)
        guard let cvTexture = cvTextureOut, let texture = CVMetalTextureGetTexture(cvTexture) else
        {
            print("Video mixer failed to create preview texture")
            
            CVMetalTextureCacheFlush(textureCache, 0)
            return nil
        }
        
        return texture
    }
}
