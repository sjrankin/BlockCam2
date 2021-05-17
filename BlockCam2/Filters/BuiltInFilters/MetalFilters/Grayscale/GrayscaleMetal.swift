//
//  GrayscaleMetal.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/15/21.
//

import Foundation
import UIKit
import CoreMedia
import CoreVideo
import MetalKit

class GrayscaleAdjust: MetalFilterParent, BuiltInFilterProtocol
{
    // MARK: - Required by BuiltInFilterProtocol.
    
    static var FilterType: BuiltInFilters = .MetalGrayscale
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
    
    required override init()
    {
        let DefaultLibrary = MetalDevice?.makeDefaultLibrary()
        let KernelFunction = DefaultLibrary?.makeFunction(name: "GrayscaleKernel")
        do
        {
            ComputePipelineState = try MetalDevice?.makeComputePipelineState(function: KernelFunction!)
        }
        catch
        {
            print("Unable to create pipeline state: \(error.localizedDescription)")
        }
    }

    
    private var BufferPool: CVPixelBufferPool? = nil
    
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
            print("LocalBufferPool is nil in GrayscaleMetal.Initialize.")
            return
        }
        InputFormatDescription = FormatDescription
        Initialized = true
        var MetalTextureCache: CVMetalTextureCache? = nil
        guard CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, MetalDevice!, nil, &MetalTextureCache) == kCVReturnSuccess else
        {
            fatalError("Unable to allocate texture cache in GrayscaleMetal.")
        }
        TextureCache = MetalTextureCache
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
        
        guard Initialized else
        {
            Debug.FatalError("GrayscaleMetal is not initialized.")
        }
        let FinalCommand = Options[.IntCommand] as? Int ?? 0
        let RMul = Options[.RedMultiplier] as? Double ?? 0.5
        let GMul = Options[.GreenMultiplier] as? Double ?? 0.5
        let BMul = Options[.BlueMultiplier] as? Double ?? 0.5
        let Parameter = GrayscaleParameters(Command: simd_int1(FinalCommand), RMultiplier: simd_float1(RMul),
                                            GMultiplier: simd_float1(GMul), BMultiplier: simd_float1(BMul))
        let Parameters = [Parameter]
        ParameterBuffer = MetalDevice!.makeBuffer(length: MemoryLayout<GrayscaleParameters>.stride, options: [])
        memcpy(ParameterBuffer.contents(), Parameters, MemoryLayout<GrayscaleParameters>.stride)
        
        super.CreateBufferPool(Source: CIImage(cvPixelBuffer: Buffer.first!), From: Buffer.first!)
        var NewPixelBuffer: CVPixelBuffer? = nil
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, super.BasePool!, &NewPixelBuffer)
        guard let OutputBuffer = NewPixelBuffer else
        {
            fatalError("Error creation textures for GrayscaleMetal.")
        }
        
        guard let InputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: Buffer.first!, TextureFormat: .bgra8Unorm) else
        {
            Debug.FatalError("Error creating textures in GrayscaleMetal.")
        }
        
        guard let OutputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: OutputBuffer, TextureFormat: .bgra8Unorm) else
        {
            Debug.FatalError("Error creating textures in GrayscaleAdjust.")
        }
        
        guard let CommandQ = CommandQueue,
              let CommandBuffer = CommandQ.makeCommandBuffer(),
              let CommandEncoder = CommandBuffer.makeComputeCommandEncoder() else
        {
            Debug.FatalError("Error creating Metal command queue.")
        }
        
        CommandEncoder.label = "Grayscale Metal Kernel"
        CommandEncoder.setComputePipelineState(ComputePipelineState!)
        CommandEncoder.setTexture(InputTexture, index: 0)
        CommandEncoder.setTexture(OutputTexture, index: 1)
        CommandEncoder.setBuffer(ParameterBuffer, offset: 0, index: 0)

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
    
    static func ResetFilter()
    {
        Settings.SetInt(.GrayscaleMetalCommand, Settings.SettingDefaults[.GrayscaleMetalCommand] as! Int)
        Settings.SetDouble(.GrayscaleRedMultiplier,
                           Settings.SettingDefaults[.GrayscaleRedMultiplier] as! Double)
        Settings.SetDouble(.GrayscaleGreenMultiplier,
                           Settings.SettingDefaults[.GrayscaleGreenMultiplier] as! Double)
        Settings.SetDouble(.GrayscaleBlueMultiplier,
                           Settings.SettingDefaults[.GrayscaleBlueMultiplier] as! Double)
    }
    
    static func GetOperationName(Index: Int) -> String
    {
        if Index < 0
        {
            return "Undefined"
        }
        if Index > GrayscaleOperations.allCases.count - 1
        {
            return "Undefined"
        }
        return GrayscaleOperations.allCases[Index].rawValue
    }
    
    static func GetOperationEnum(Index: Int) -> GrayscaleOperations
    {
        if Index < 0
        {
            return .Mean
        }
        if Index > GrayscaleOperations.allCases.count - 1
        {
            return .Mean
        }
        return GrayscaleOperations.allCases[Index]
    }
}

enum GrayscaleOperations: String, CaseIterable
{
    case Mean = "Mean"
    case Luminance = "Luminance"
    case Desaturation = "Desaturation"
    case BT601 = "BT601"
    case BT709 = "BT709"
    case MaxDecomposition = "Max Decomposition"
    case MinDecomposition = "Min Decomposition"
    case Red = "Red Channel"
    case Green = "Green Channel"
    case Blue = "Blue Channel"
    case Cyan = "Cyan Channel"
    case Magenta = "Magenta Channel"
    case Yellow = "Yellow Channel"
    case CMYKCyan = "CMYK Cyan"
    case CMYKMagenta = "CMYK Magenta"
    case CMYKYellow = "CMYK Yellow"
    case CMYKBlack = "CMYK Black"
    case Hue = "Hue"
    case Saturation = "Saturation"
    case Brightness = "Brightness"
    case MeanCMYK = "Mean CMYK"
    case MeanHSB = "Mean HSB"
    case User = "User Parameters"
}
