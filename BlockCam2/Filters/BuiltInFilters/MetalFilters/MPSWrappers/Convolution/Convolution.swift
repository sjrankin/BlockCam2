//
//  Convolution.swift
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

class MPSConvolution: MetalFilterParent, BuiltInFilterProtocol
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
            print("BufferPool nil in MPSConvolution.Initialize.")
            return
        }
        InputFormatDescription = FormatDescription
        CommandQueue = MetalDevice?.makeCommandQueue()
        bciContext = CIContext()
        Initialized = true
        var MetalTextureCache: CVMetalTextureCache? = nil
        if CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, MetalDevice!, nil, &MetalTextureCache) != kCVReturnSuccess
        {
            fatalError("Unable to allocation texture cache in MPSConvolution.")
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
            fatalError("MPSConvolution not initialized.")
        }
        
        var NewPixelBuffer: CVPixelBuffer? = nil
        
        super.CreateBufferPool(Source: CIImage(cvPixelBuffer: PixelBuffer.first!), From: PixelBuffer.first!)
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, super.BasePool!, &NewPixelBuffer)
        guard let OutputBuffer = NewPixelBuffer else
        {
            Debug.FatalError("Error creating buffer pool for MPSConvolution.")
        }
        
        guard let InputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: PixelBuffer.first!,
                                                              TextureFormat: .bgra8Unorm) else
        {
            print("Error creating input texture in MPSConvolution.")
            return PixelBuffer.first!
        }
        guard let OutputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: OutputBuffer,
                                                               TextureFormat: .bgra8Unorm) else
        {
            print("Error creating output texture in MPSConvolution.")
            return PixelBuffer.first!
        }
        
        guard let CommandQ = CommandQueue,
              let CommandBuffer = CommandQ.makeCommandBuffer() else
        {
            print("Error creating Metal command queue in MPSConvolution.")
            CVMetalTextureCacheFlush(TextureCache!, 0)
            return PixelBuffer.first!
        }
        
        let DMatrix = Options[.Matrix] as? [[Double]] ?? [[1.0, 0.0, 0.0], [0.0, 1.0, 0.0], [0.0, 0.0, 1.0]]
        var Matrix = [Float]()
        let MatrixWidth = Options[.Width] as? Int ?? 3
        let MatrixHeight = Options[.Height] as? Int ?? 3
        guard !Int(MatrixWidth).isMultiple(of: 2) && !Int(MatrixHeight).isMultiple(of: 2) else
        {
            Debug.FatalError("Matrix kernel in Convolution must have odd dimensions: Width=\(Int(MatrixWidth)), Height=\(Int(MatrixHeight))")
        }
        for Y in 0 ..< MatrixHeight
        {
            for X in 0 ..< MatrixWidth
            {
                Matrix.append(Float(DMatrix[Y][X]))
            }
        }
        let Bias = Float(Options[.Bias] as? Double ?? 0.0)
        
        let Shader = MPSImageConvolution(device: MetalDevice!, kernelWidth: MatrixWidth,
                                         kernelHeight: MatrixHeight, weights: Matrix)
        Shader.bias = Bias
        Shader.edgeMode = .clamp
        Shader.encode(commandBuffer: CommandBuffer, sourceTexture: InputTexture, destinationTexture: OutputTexture )
        CommandBuffer.commit()
        CommandBuffer.waitUntilCompleted()
        
        return OutputBuffer
    }
    
    /// Reset the filter's settings.
    static func ResetFilter()
    {
    }
    
    static func GetKernelName(Index: Int) -> String
    {
        if Index < 0
        {
            return "Undefined"
        }
        if Index > ConvolutionKernels.allCases.count - 1
        {
            return "Undefined"
        }
        return ConvolutionKernels.allCases[Index].rawValue
    }
    
    static func GetKernelEnum(Index: Int) -> ConvolutionKernels
    {
        if Index < 0
        {
            return .Custom
        }
        if Index > ConvolutionKernels.allCases.count - 1
        {
            return .Custom
        }
        return ConvolutionKernels.allCases[Index]
    }
    
    static func GetPredefinedKernel(Index OfKernel: Int) -> [[Double]]
    {
        let Which = GetKernelEnum(Index: OfKernel)
        if Which == .Custom
        {
            return [[0.0]]
        }
        guard let KernelData = StandardKernels[Which] else
        {
            return [[0.0]]
        }
        return KernelData
    }
}

enum ConvolutionKernels: String, CaseIterable
{
    case Custom = "Custom"
    case Identity = "Identity"
    case EdgeDetection0 = "Weak Edge Detection"
    case EdgeDetection1 = "Edge Detection"
    case EdgeDetection2 = "Strong Edge Detection"
    case Sharpen = "Sharpen"
    case SharpenDeblur = "Sharpen & Deblur"
    case BoxBlur = "Box Blur"
    case Roberts = "Roberts"
    case Kirsch = "Kirsch"
    case FreiChen = "Frei-Chen"
    case Lagrangian = "Lagrangian"
}

extension MPSConvolution
{
    static var StandardKernels: [ConvolutionKernels: [[Double]]] =
        [
            .Identity:
                [
                    [0.0, 0.0, 0.0, 0.0, 0.0],
                    [0.0, 1.0, 0.0, 0.0, 0.0],
                    [0.0, 0.0, 0.0, 0.0, 0.0],
                    [0.0, 0.0, 0.0, 0.0, 0.0],
                    [0.0, 0.0, 0.0, 0.0, 0.0],
                ],
            .EdgeDetection0:
                [
                    [0.0, 0.0, -1.0, 0.0, 0.0],
                    [0.0, 0.0, 0.0, 0.0, 0.0],
                    [-1.0, 0.0, 1.0, 0.0, 0.0],
                    [0.0, 0.0, 0.0, 0.0, 0.0],
                    [0.0, 0.0, 0.0, 0.0, 0.0],
                ],
            .EdgeDetection1:
                [
                    [0.0, -1.0, 0.0, 0.0, 0.0],
                    [-1.0, 4.0, 1.0, 0.0, 0.0],
                    [0.0, -1.0, 0.0, 0.0, 0.0],
                    [0.0, 0.0, 0.0, 0.0, 0.0],
                    [0.0, 0.0, 0.0, 0.0, 0.0],
                ],
            .EdgeDetection2:
                [
                    [-1.0, -1.0, -1.0, 0.0, 0.0],
                    [-1.0, 8.0, -1.0, 0.0, 0.0],
                    [-1.0, -1.0, -1.0, 0.0, 0.0],
                    [0.0, 0.0, 0.0, 0.0, 0.0],
                    [0.0, 0.0, 0.0, 0.0, 0.0],
                ],
            .Sharpen:
                [
                    [0.0, -1.0, 0.0, 0.0, 0.0],
                    [-1.0, 5.0, -1.0, 0.0, 0.0],
                    [0.0, -1.0, 0.0, 0.0, 0.0],
                    [0.0, 0.0, 0.0, 0.0, 0.0],
                    [0.0, 0.0, 0.0, 0.0, 0.0],
                ],
            .BoxBlur:
                [
                    [1.0 / 9.0, 1.0 / 9.0, 1.0 / 9.0, 0.0, 0.0],
                    [1.0 / 9.0, 1.0 / 9.0, 1.0 / 9.0, 0.0, 0.0],
                    [1.0 / 9.0, 1.0 / 9.0, 1.0 / 9.0, 0.0, 0.0],
                    [0.0, 0.0, 0.0, 0.0, 0.0],
                    [0.0, 0.0, 0.0, 0.0, 0.0],
                ],
            .SharpenDeblur:
                [
                    [-0.5, -1.0, -0.5, 0.0, 0.0],
                    [-1.0, 7.0, -1.0, 0.0, 0.0],
                    [-0.5, -1.0, -0.5, 0.0, 0.0],
                    [0.0, 0.0, 0.0, 0.0, 0.0],
                    [0.0, 0.0, 0.0, 0.0, 0.0],
                ],
            .Roberts:
            [
                [0.0, 0.0, 0.0, 0.0, 0.0],
                [1.0, -1.0, 0.0, 0.0, 0.0],
                [0.0, 0.0, 0.0, 0.0, 0.0],
                [0.0, 0.0, 0.0, 0.0, 0.0],
                [0.0, 0.0, 0.0, 0.0, 0.0],
            ],
            .Kirsch:
            [
                [5.0, -3.0, -3.0, 0.0, 0.0],
                [5.0, 0.0, -3.0, 0.0, 0.0],
                [5.0, -3.0, -3.0, 0.0, 0.0],
                [0.0, 0.0, 0.0, 0.0, 0.0],
                [0.0, 0.0, 0.0, 0.0, 0.0],
            ],
            .FreiChen:
            [
                [1.0, 0.0, -1.0, 0.0, 0.0],
                [1.41421, 0.0, -1.41421, 0.0, 0.0],
                [1.0, 0.0, -1.0, 0.0, 0.0],
                [0.0, 0.0, 0.0, 0.0, 0.0],
                [0.0, 0.0, 0.0, 0.0, 0.0],
            ],
            .Lagrangian:
            [
                [0.0, -1.0, 0.0, 0.0, 0.0],
                [-1.0, 4.0, -1.0, 0.0, 0.0],
                [0.0, -1.0, 0.0, 0.0, 0.0],
                [0.0, 0.0, 0.0, 0.0, 0.0],
                [0.0, 0.0, 0.0, 0.0, 0.0],
            ]
        ]
}
