//
//  Erode.swift
//  BlockCam2
//  Adapted from BumpCamera, 3/21/19.
//
//  Created by Stuart Rankin on 4/26/21.
//

import Foundation
import UIKit
import CoreMedia
import CoreVideo
import MetalKit
import MetalPerformanceShaders

class Erode: MetalFilterParent, BuiltInFilterProtocol
{
    static var FilterType: BuiltInFilters = .Erode
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
            print("BufferPool nil in MPSLaplacian.Initialize.")
            return
        }
        InputFormatDescription = FormatDescription
        CommandQueue = MetalDevice?.makeCommandQueue()
        bciContext = CIContext()
        Initialized = true
        var MetalTextureCache: CVMetalTextureCache? = nil
        if CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, MetalDevice!, nil, &MetalTextureCache) != kCVReturnSuccess
        {
            fatalError("Unable to allocation texture cache in MPSLaplacian.")
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
    
    func RunFilter(_ PixelBuffer: CVPixelBuffer, _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace, Options: [FilterOptions : Any]) -> CVPixelBuffer
    {
        objc_sync_enter(AccessLock)
        defer{objc_sync_exit(AccessLock)}
        
        let Start = CACurrentMediaTime()
        if !Initialized
        {
            fatalError("MPSLaplacian not initialized at Render(CVPixelBuffer) call.")
        }
        
        var NewPixelBuffer: CVPixelBuffer? = nil
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, LocalBufferPool!, &NewPixelBuffer)
        guard let OutputBuffer = NewPixelBuffer else
        {
            print("Allocation failure for new pixel buffer pool in MPSLaplacian.")
            return PixelBuffer
        }
        
        guard let InputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: PixelBuffer, TextureFormat: .bgra8Unorm) else
        {
            print("Error creating input texture in MPSLaplacian.")
            return PixelBuffer
        }
        guard let OutputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: OutputBuffer, TextureFormat: .bgra8Unorm) else
        {
            print("Error creating output texture in MPSLaplacian.")
            return PixelBuffer
        }
        
        guard let CommandQ = CommandQueue,
              let CommandBuffer = CommandQ.makeCommandBuffer() else
        {
            print("Error creating Metal command queue in MPSLaplacian.")
            CVMetalTextureCacheFlush(TextureCache!, 0)
            return PixelBuffer
        }
        
        let KWidth = Options[.ErodeWidth] as? Int ?? 3
        let KHeight = Options[.ErodeHeight] as? Int ?? 3
        let Probe = CreateProbe(KWidth, KHeight)
        let Shader = MPSImageErode(device: MetalDevice!, kernelWidth: KWidth, kernelHeight: KHeight, values: UnsafePointer(Probe))
        Shader.encode(commandBuffer: CommandBuffer, sourceTexture: InputTexture, destinationTexture: OutputTexture)
        CommandBuffer.commit()
        CommandBuffer.waitUntilCompleted()
        
        return OutputBuffer
    }
    
    /// Calculate the center of an odd-sized matrix.
    /// - Parameters:
    ///   - Width: Width of the matrix. Should be an odd number.
    ///   - Height: Height of the matrix. Should be an odd number.
    /// - Returns: The index, horizontal, and vertical centers.
    func CalculateCenter(Width: Int, Height: Int) -> (Int, Int, Int)
    {
        //Get the coordinates of the center.
        let MV = (Height / 2) + 1
        let MH = (Width / 2) + 1
        //Generate the index of the coordinates.
        let Index = (MV * Width) + MH
        return (Index, MH, MV)
    }
    
    /// Return the distance between the two passed points.
    /// - Parameters:
    ///   - From: First point.
    ///   - To: Second point.
    /// - Returns: Distance between the two, passed points.
    func Distance(From: (Int, Int), To: (Int, Int)) -> Double
    {
        let Xsq = (To.0 - To.1) * (To.0 - To.1)
        let Ysq = (To.0 - To.1) * (To.0 - To.1)
        return sqrt(Double(Xsq + Ysq))
    }
    
    /// Create the probe matrix for the MPS kernel.
    /// - Parameters:
    ///   - Width: Width of the kernel.
    ///   - Height: Height of the kernel.
    /// - Returns: Populated kernel to use as the probe.
    func CreateProbe(_ Width: Int, _ Height: Int) -> [Float]
    {
        var Probe = [Float](repeating: 0.0, count: Width * Height)
        let (Center, CenterX, CenterY) = CalculateCenter(Width: Width, Height: Height)
        let MaxDistance = Distance(From: (0,0), To: (CenterX, CenterY))
        
        for Y in 0 ..< Height
        {
            for X in 0 ..< Width
            {
                let Dist = Distance(From: (X,Y), To: (CenterX, CenterY))
                var Final = Dist / MaxDistance
                Final = Y % 2 == 0 ? 1.0 : 0.0
                let Index = (Y * Width) + X
                Probe[Index] = Float(Final)
            }
        }
        
        Probe[Center] = 0.0
        return Probe
    }
}
