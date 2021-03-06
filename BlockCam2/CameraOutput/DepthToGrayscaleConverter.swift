//
//  DepthToGrayscaleConverter.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/18/21.
//

import Foundation
import CoreMedia
import CoreVideo
import Metal

class DepthToGrayscaleConverter
{
    var description: String = "Depth to Grayscale Converter"
    
    var isPrepared = false
    
    private(set) var inputFormatDescription: CMFormatDescription?
    
    private(set) var outputFormatDescription: CMFormatDescription?
    
    private var inputTextureFormat: MTLPixelFormat = .invalid
    
    private var outputPixelBufferPool: CVPixelBufferPool!
    
    private let metalDevice = MTLCreateSystemDefaultDevice()!
    
    private var computePipelineState: MTLComputePipelineState?
    
    private lazy var commandQueue: MTLCommandQueue? =
        {
            return self.metalDevice.makeCommandQueue()
        }()
    
    private var textureCache: CVMetalTextureCache!
    
    private var lowest: Float = 0.0
    
    private var highest: Float = 0.0
    
    struct DepthRenderParam {
        var offset: Float
        var range: Float
    }
    
    var range: DepthRenderParam = DepthRenderParam(offset: -4.0, range: 8.0)
    
    required init()
    {
        let defaultLibrary = metalDevice.makeDefaultLibrary()!
        let kernelFunction = defaultLibrary.makeFunction(name: "depthToGrayscale")
        do
        {
            computePipelineState = try metalDevice.makeComputePipelineState(function: kernelFunction!)
        }
        catch
        {
            fatalError("Unable to create depth converter pipeline state. (\(error.localizedDescription))")
        }
    }
    
    static private func allocateOutputBufferPool(with formatDescription: CMFormatDescription, outputRetainedBufferCountHint: Int) -> CVPixelBufferPool?
    {
        let inputDimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)
        let outputPixelBufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey as String: Int(inputDimensions.width),
            kCVPixelBufferHeightKey as String: Int(inputDimensions.height),
            kCVPixelBufferIOSurfacePropertiesKey as String: [:]
        ]
        
        let poolAttributes = [kCVPixelBufferPoolMinimumBufferCountKey as String: outputRetainedBufferCountHint]
        var cvPixelBufferPool: CVPixelBufferPool?
        // Create a pixel buffer pool with the same pixel attributes as the input format description
        CVPixelBufferPoolCreate(kCFAllocatorDefault, poolAttributes as NSDictionary?, outputPixelBufferAttributes as NSDictionary?, &cvPixelBufferPool)
        guard let pixelBufferPool = cvPixelBufferPool else
        {
            assertionFailure("Allocation failure: Could not create pixel buffer pool")
            return nil
        }
        return pixelBufferPool
    }
    
    func prepare(with formatDescription: CMFormatDescription, outputRetainedBufferCountHint: Int)
    {
        reset()
        
        outputPixelBufferPool = DepthToGrayscaleConverter.allocateOutputBufferPool(with: formatDescription,
                                                                                   outputRetainedBufferCountHint: outputRetainedBufferCountHint)
        if outputPixelBufferPool == nil
        {
            return
        }
        
        var pixelBuffer: CVPixelBuffer?
        var pixelBufferFormatDescription: CMFormatDescription?
        _ = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, outputPixelBufferPool!, &pixelBuffer)
        if let pixelBuffer = pixelBuffer
        {
            CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: pixelBuffer, formatDescriptionOut: &pixelBufferFormatDescription)
        }
        pixelBuffer = nil
        
        inputFormatDescription = formatDescription
        outputFormatDescription = pixelBufferFormatDescription
        
        let inputMediaSubType = CMFormatDescriptionGetMediaSubType(formatDescription)
        if inputMediaSubType == kCVPixelFormatType_DepthFloat16 ||
            inputMediaSubType == kCVPixelFormatType_DisparityFloat16 {
            inputTextureFormat = .r16Float
        }
        else
        if inputMediaSubType == kCVPixelFormatType_DepthFloat32 ||
            inputMediaSubType == kCVPixelFormatType_DisparityFloat32
        {
            inputTextureFormat = .r32Float
        }
        else
        {
            assertionFailure("Input format not supported")
        }
        
        var metalTextureCache: CVMetalTextureCache?
        if CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, metalDevice, nil, &metalTextureCache) != kCVReturnSuccess
        {
            assertionFailure("Unable to allocate depth converter texture cache")
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
    
    // MARK: - Depth to Grayscale Conversion
    func render(pixelBuffer: CVPixelBuffer) -> CVPixelBuffer?
    {
        if !isPrepared
        {
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
        
        guard let outputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: outputPixelBuffer, TextureFormat: .bgra8Unorm),
              let inputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: pixelBuffer, TextureFormat: inputTextureFormat) else
        {
            return nil
        }
        
        var min: Float = 0.0
        var max: Float = 0.0
        minMaxFromPixelBuffer(pixelBuffer, &min, &max, inputTextureFormat)  
        if min < lowest
        {
            lowest = min
        }
        if max > highest
        {
            highest = max
        }
        range = DepthRenderParam(offset: lowest, range: highest - lowest)
        
        // Set up command queue, buffer, and encoder
        guard let commandQueue = commandQueue,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let commandEncoder = commandBuffer.makeComputeCommandEncoder() else
        {
            print("Failed to create Metal command queue")
            CVMetalTextureCacheFlush(textureCache!, 0)
            return nil
        }
        
        commandEncoder.label = "Depth to Grayscale"
        commandEncoder.setComputePipelineState(computePipelineState!)
        commandEncoder.setTexture(inputTexture, index: 0)
        commandEncoder.setTexture(outputTexture, index: 1)
        commandEncoder.setBytes( UnsafeMutableRawPointer(&range), length: MemoryLayout<DepthRenderParam>.size, index: 0)
        
        // Set up thread groups as described in https://developer.apple.com/reference/metal/mtlcomputecommandencoder
        let w = computePipelineState!.threadExecutionWidth
        let h = computePipelineState!.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSizeMake(w, h, 1)
        let threadgroupsPerGrid = MTLSize(width: (inputTexture.width + w - 1) / w,
                                          height: (inputTexture.height + h - 1) / h,
                                          depth: 1)
        commandEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        
        commandEncoder.endEncoding()
        
        commandBuffer.commit()
        
        return outputPixelBuffer
    }
    
    func MakeTextureFromCVPixelBuffer(PixelBuffer: CVPixelBuffer, TextureFormat: MTLPixelFormat) -> MTLTexture?
    {
        let width = CVPixelBufferGetWidth(PixelBuffer)
        let height = CVPixelBufferGetHeight(PixelBuffer)
        
        // Create a Metal texture from the image buffer
        var cvTextureOut: CVMetalTexture?
        CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, PixelBuffer, nil, TextureFormat, width, height, 0, &cvTextureOut)
        guard let cvTexture = cvTextureOut, let texture = CVMetalTextureGetTexture(cvTexture) else
        {
            print("Depth converter failed to create preview texture")
            
            CVMetalTextureCacheFlush(textureCache, 0)
            
            return nil
        }
        
        return texture
    }
    
}
