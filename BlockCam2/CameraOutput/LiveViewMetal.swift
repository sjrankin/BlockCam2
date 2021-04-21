//
//  LiveViewMetal.swift
//  BlockCam2
//  Adapted from Apple sample code.
//
//  Created by Stuart Rankin on 4/18/21.
//

import Foundation
import CoreMedia
import Metal
import MetalKit

/// `MTKView` that acts as a live view for camera output.
/// - Note:
///   - This implementation assumes the instance is created in code and not in the InterfaceBuilder. This
///     implies the constructors do not need to be overridden but some form of initialization is required
///     so users of this class **must** call `Initialization`.
///   - See [Cameras and media capture](https://developer.apple.com/documentation/avfoundation/cameras_and_media_capture/avcamfilter_applying_filters_to_a_capture_stream)
class LiveMetalView: MTKView
{
    /// Initialization.
    /// - Parameter Frame: The frame where the view will live.
    func Initialize(_ Frame: CGRect)
    {
        self.frame = Frame
        device = MTLCreateSystemDefaultDevice()
        ConfigureMetal()
        CreateTextureCache()
        colorPixelFormat = .bgra8Unorm
    }
    
    /// Standard UI rotations.
    /// - rotate0Degrees: At 0° rotation.
    /// - rotate90Degrees: At 90° rotation.
    /// - rotate180Degrees: At 180° rotation.
    /// - rotate270Degrees: At 270° rotation.
    enum ViewRotations: Int
    {
        case rotate0Degrees
        case rotate90Degrees
        case rotate180Degrees
        case rotate270Degrees
    }
    
    /// Sets the internal mirroring flag.
    var Mirroring = false
    {
        didSet
        {
            SyncQueue.sync
            {
                InternalMirroring = Mirroring
            }
        }
    }
    
    /// Holds the mirror flag value.
    private var InternalMirroring: Bool = false
    
    /// Set the current rotation of the view.
    var rotation: ViewRotations = .rotate0Degrees
    {
        didSet
        {
            SyncQueue.sync
            {
                InternalRotation = rotation
            }
        }
    }
    
    /// Holds the current rotational value.
    private var InternalRotation: ViewRotations = .rotate0Degrees
    
    /// Pixel buffer lock.
    var PixelBufferLock = NSObject()
    
    /// Get the current pixel buffer. Nil returned if not available.
    var pixelBuffer: CVPixelBuffer?
    {
        didSet
        {
            SyncQueue.sync
            {
                objc_sync_enter(PixelBufferLock)
                defer {objc_sync_exit(PixelBufferLock)}
                InternalPixelBuffer = pixelBuffer
            }
        }
    }
    
    /// Internal pixel buffer.
    private var InternalPixelBuffer: CVPixelBuffer?
    /// Synchronization queue.
    private let SyncQueue = DispatchQueue(label: "Preview View Sync Queue",
                                          qos: .userInitiated, attributes: [],
                                          autoreleaseFrequency: .workItem)
    /// Texture cache for the view.
    private var TextureCache: CVMetalTextureCache?
    /// Width of the texture.
    private var TextureWidth: Int = 0
    /// Height of the texture.
    private var TextureHeight: Int = 0
    /// Texture mirroring flag.
    private var TextureMirroring = false
    /// Current texture rotation.
    private var TextureRotation: ViewRotations = .rotate0Degrees
    /// Sample state.
    private var Sampler: MTLSamplerState!
    /// Render pipeline state.
    private var RenderPipelineState: MTLRenderPipelineState!
    /// Command queue for controlling the view.
    private var CommandQueue: MTLCommandQueue?
    /// Vertex coordinate buffer.
    private var VertexCoordinatesBuffer: MTLBuffer!
    /// Texture coordinate buffer.
    private var TextCoordinateBuffer: MTLBuffer!
    /// Internal bounds.
    private var InternalBounds: CGRect!
    /// Texture transform matrix.
    private var TextureTranform: CGAffineTransform?
    
    /// Returns the point in the texture based on the view's point.
    /// - Parameter ViewPoint: The point in the view to convert.
    func TexturePointForView(ViewPoint: CGPoint) -> CGPoint?
    {
        var result: CGPoint?
        guard let transform = TextureTranform else
        {
            return result
        }
        let transformPoint = ViewPoint.applying(transform)
        
        if CGRect(origin: .zero, size: CGSize(width: TextureWidth, height: TextureHeight)).contains(transformPoint)
        {
            result = transformPoint
        }
        else
        {
            print("Invalid point \(ViewPoint) result point \(transformPoint)")
        }
        
        return result
    }
    
    /// Returns the point in the view for a texture point.
    /// - Parameter TexturePoint: The point in the texture to convert.
    func viewPointForTexture(TexturePoint: CGPoint) -> CGPoint?
    {
        var result: CGPoint?
        guard let transform = TextureTranform?.inverted() else
        {
            return result
        }
        let transformPoint = TexturePoint.applying(transform)
        
        if InternalBounds.contains(transformPoint)
        {
            result = transformPoint
        }
        else
        {
            print("Invalid point \(TexturePoint) result point \(transformPoint)")
        }
        
        return result
    }
    
    /// Flush the texture cache.
    func FlushTextureCache()
    {
        TextureCache = nil
    }
    
    /// Setup the transform for the view.
    /// - Parameter Width: The width of the view.
    /// - Parameter Height: The height of the view.
    /// - Parameter Mirroring: Mirroring of the view.
    /// - Parameter ViewRotation: Interface rotation.
    private func SetupTransform(Width: Int, Height: Int, Mirroring: Bool, ViewRotation: ViewRotations)
    {
        var scaleX: Float = 1.0
        var scaleY: Float = 1.0
        var resizeAspect: Float = 1.0
        
        InternalBounds = self.bounds
        TextureWidth = Width
        TextureHeight = Height
        TextureMirroring = Mirroring
        TextureRotation = ViewRotation
        
        if TextureWidth > 0 && TextureHeight > 0
        {
            switch TextureRotation
            {
                case .rotate0Degrees, .rotate180Degrees:
                    scaleX = Float(InternalBounds.width / CGFloat(TextureWidth))
                    scaleY = Float(InternalBounds.height / CGFloat(TextureHeight))
                    
                case .rotate90Degrees, .rotate270Degrees:
                    scaleX = Float(InternalBounds.width / CGFloat(TextureHeight))
                    scaleY = Float(InternalBounds.height / CGFloat(TextureWidth))
            }
        }
        // Resize aspect
        resizeAspect = min(scaleX, scaleY)
        if scaleX < scaleY
        {
            scaleY = scaleX / scaleY
            scaleX = 1.0
        }
        else
        {
            scaleX = scaleY / scaleX
            scaleY = 1.0
        }
        
        if TextureMirroring
        {
            scaleX *= -1.0
        }
        
        // Vertex coordinate takes the gravity into account
        let vertexData: [Float] =
            [
                -scaleX, -scaleY, 0.0, 1.0,
                scaleX,  -scaleY, 0.0, 1.0,
                -scaleX, scaleY,  0.0, 1.0,
                scaleX,  scaleY,  0.0, 1.0
            ]
        VertexCoordinatesBuffer = device!.makeBuffer(bytes: vertexData, length: vertexData.count * MemoryLayout<Float>.size, options: [])
        
        // Texture coordinate takes the rotation into account
        var textData: [Float]
        switch TextureRotation
        {
            case .rotate0Degrees:
                textData =
                    [
                        0.0, 1.0,
                        1.0, 1.0,
                        0.0, 0.0,
                        1.0, 0.0
                    ]
                
            case .rotate180Degrees:
                textData =
                    [
                        1.0, 0.0,
                        0.0, 0.0,
                        1.0, 1.0,
                        0.0, 1.0
                    ]
                
            case .rotate90Degrees:
                textData =
                    [
                        1.0, 1.0,
                        1.0, 0.0,
                        0.0, 1.0,
                        0.0, 0.0
                    ]
                
            case .rotate270Degrees:
                textData =
                    [
                        0.0, 0.0,
                        0.0, 1.0,
                        1.0, 0.0,
                        1.0, 1.0
                    ]
        }
        TextCoordinateBuffer = device?.makeBuffer(bytes: textData, length: textData.count * MemoryLayout<Float>.size, options: [])
        
        // Calculate the transform from texture coordinates to view coordinates
        var transform = CGAffineTransform.identity
        if TextureMirroring
        {
            transform = transform.concatenating(CGAffineTransform(scaleX: -1, y: 1))
            transform = transform.concatenating(CGAffineTransform(translationX: CGFloat(TextureWidth), y: 0))
        }
        
        switch TextureRotation
        {
            case .rotate0Degrees:
                transform = transform.concatenating(CGAffineTransform(rotationAngle: CGFloat(0)))
                
            case .rotate180Degrees:
                transform = transform.concatenating(CGAffineTransform(rotationAngle: CGFloat(Double.pi)))
                transform = transform.concatenating(CGAffineTransform(translationX: CGFloat(TextureWidth),
                                                                      y: CGFloat(TextureHeight)))
                
            case .rotate90Degrees:
                transform = transform.concatenating(CGAffineTransform(rotationAngle: CGFloat(Double.pi) / 2))
                transform = transform.concatenating(CGAffineTransform(translationX: CGFloat(TextureHeight), y: 0))
                
            case .rotate270Degrees:
                transform = transform.concatenating(CGAffineTransform(rotationAngle: 3 * CGFloat(Double.pi) / 2))
                transform = transform.concatenating(CGAffineTransform(translationX: 0, y: CGFloat(TextureWidth)))
        }
        
        transform = transform.concatenating(CGAffineTransform(scaleX: CGFloat(resizeAspect), y: CGFloat(resizeAspect)))
        let tranformRect = CGRect(origin: .zero, size: CGSize(width: TextureWidth, height: TextureHeight)).applying(transform)
        let tx = (InternalBounds.size.width - tranformRect.size.width) / 2
        let ty = (InternalBounds.size.height - tranformRect.size.height) / 2
        transform = transform.concatenating(CGAffineTransform(translationX: tx, y: ty))
        TextureTranform = transform.inverted()
    }
    
    /// Configure Metal to run the live view.
    func ConfigureMetal()
    {
        if let defaultLibrary = device!.makeDefaultLibrary()
        {
            print("Configuring Metal in LiveMetalView.")
            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.label = "LiveMetalView.RenderPipeline"
            pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            pipelineDescriptor.vertexFunction = defaultLibrary.makeFunction(name: "vertexPassThrough")
            pipelineDescriptor.fragmentFunction = defaultLibrary.makeFunction(name: "fragmentPassThrough")
            
            // To determine how our textures are sampled, we create a sampler descriptor, which
            // will be used to ask for a sampler state object from our device below.
            let samplerDescriptor = MTLSamplerDescriptor()
            samplerDescriptor.label = "LiveMetalView.sampler"
            samplerDescriptor.sAddressMode = .clampToEdge
            samplerDescriptor.tAddressMode = .clampToEdge
            samplerDescriptor.minFilter = .linear
            samplerDescriptor.magFilter = .linear
            Sampler = device!.makeSamplerState(descriptor: samplerDescriptor)
            if Sampler != nil
            {
                do
                {
                    RenderPipelineState = try device!.makeRenderPipelineState(descriptor: pipelineDescriptor)
                }
                catch
                {
                    fatalError("Unable to create preview Metal view pipeline state. (\(error))")
                }
                
                CommandQueue = device!.makeCommandQueue()
            }
            else
            {
                print("Error creating sampler.")
            }
        }
        else
        {
            print("Error creating default library.")
        }
    }
    
    /// Create the texture cache.
    func CreateTextureCache()
    {
        var newTextureCache: CVMetalTextureCache?
        if CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device!, nil, &newTextureCache) == kCVReturnSuccess
        {
            TextureCache = newTextureCache
        }
        else
        {
            assertionFailure("Unable to allocate texture cache")
        }
    }
    
    /// Drawing lock object.
    var DrawingLock = NSObject()
    
    /// Draw the live view.
    /// - Parameter rect: Where to draw the view.
    override func draw(_ rect: CGRect)
    {
        objc_sync_enter(DrawingLock)
        defer {objc_sync_exit(DrawingLock)}
        var pixelBuffer: CVPixelBuffer?
        var mirroring = false
        var rotation: ViewRotations = .rotate0Degrees
        
        SyncQueue.sync
        {
            pixelBuffer = InternalPixelBuffer
            mirroring = InternalMirroring
            rotation = InternalRotation
        }
        
        guard let drawable = currentDrawable,
              let currentRenderPassDescriptor = currentRenderPassDescriptor,
              let previewPixelBuffer = pixelBuffer else
        {
            return
        }
        currentRenderPassDescriptor.accessibilityLabel = "LiveMetalView.currentRenderPassDescriptor"
        
        // Create a Metal texture from the image buffer
        let width = CVPixelBufferGetWidth(previewPixelBuffer)
        let height = CVPixelBufferGetHeight(previewPixelBuffer)
        
        if TextureCache == nil
        {
            CreateTextureCache()
        }
        var cvTextureOut: CVMetalTexture?
        CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                  TextureCache!,
                                                  previewPixelBuffer,
                                                  nil,
                                                  .bgra8Unorm,
                                                  width,
                                                  height,
                                                  0,
                                                  &cvTextureOut)
        guard let cvTexture = cvTextureOut, let texture = CVMetalTextureGetTexture(cvTexture) else
        {
            print("LiveMetalView: Failed to create preview texture")
            CVMetalTextureCacheFlush(TextureCache!, 0)
            return
        }
        
        if texture.width != TextureWidth ||
            texture.height != TextureHeight ||
            self.bounds != InternalBounds ||
            mirroring != TextureMirroring ||
            rotation != TextureRotation
        {
            SetupTransform(Width: texture.width, Height: texture.height, Mirroring: mirroring, ViewRotation: rotation)
        }
        
        // Set up command buffer and encoder
        guard let commandQueue = CommandQueue else
        {
            print("Failed to create Metal command queue")
            CVMetalTextureCacheFlush(TextureCache!, 0)
            return
        }
        
        guard let commandBuffer = commandQueue.makeCommandBuffer() else
        {
            print("Failed to create Metal command buffer")
            CVMetalTextureCacheFlush(TextureCache!, 0)
            return
        }
        
        guard let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: currentRenderPassDescriptor) else
        {
            print("Failed to create Metal command encoder")
            CVMetalTextureCacheFlush(TextureCache!, 0)
            return
        }
        
        commandEncoder.label = "Metal Live View Display"
        commandEncoder.setRenderPipelineState(RenderPipelineState!)
        commandEncoder.setVertexBuffer(VertexCoordinatesBuffer, offset: 0, index: 0)
        commandEncoder.setVertexBuffer(TextCoordinateBuffer, offset: 0, index: 1)
        commandEncoder.setFragmentTexture(texture, index: 0)
        commandEncoder.setFragmentSamplerState(Sampler, index: 0)
        commandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        commandEncoder.endEncoding()
        
        commandBuffer.present(drawable) // Draw to the screen
        commandBuffer.commit()
    }
}
