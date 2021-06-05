//
//  Arithmetic.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 6/4/21.
//

import Foundation
import UIKit
import CoreMedia
import CoreVideo
import MetalKit

class Arithmetic: MetalFilterParent, BuiltInFilterProtocol
{
    // MARK: - Required by BuiltInFilterProtocol.
    
    static var FilterType: BuiltInFilters = .SimpleArithmetic
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
            print("LocalBufferPool is nil in Arithmetic.Initialize.")
            return
        }
        InputFormatDescription = FormatDescription
        Initialized = true
        var MetalTextureCache: CVMetalTextureCache? = nil
        guard CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, MetalDevice!, nil, &MetalTextureCache) == kCVReturnSuccess else
        {
            Debug.FatalError("Unable to allocate texture cache in Arithmetic.")
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
            fatalError("Arithmetic not initialized.")
        }
        objc_sync_enter(AccessLock)
        defer{objc_sync_exit(AccessLock)}
        
        let Op = Options[.ArithmeticOperation] as! Int
        guard let Operation = ArithmeticOperations(rawValue: Op) else
        {
            Debug.Print("Unexpected arithmetic operation: \(Op)")
            return Buffer.first!
        }
        let UseR = Options[.ArithmeticUseChannelR] as! Bool
        let UseG = Options[.ArithmeticUseChannelG] as! Bool
        let UseB = Options[.ArithmeticUseChannelB] as! Bool
        let UseA = Options[.ArithmeticUseChannelA] as! Bool
        let KernelSuffix = "\(UseR ? "R" : "")\(UseG ? "G" : "")\(UseB ? "B" : "")"
        
        var KernelName = ""
        print("Arithmetic Operation=\(Operation)")
        switch Operation
        {
            case .AddConstant:
                if KernelSuffix.isEmpty
                {
                    return Buffer.first!
                }
                KernelName = "Arithmetic_AddConstant" + KernelSuffix
                return ConstantFilter(Buffer, Operation: .AddConstant, KernelName, Options)
                
            case .AddToAccumulator:
                KernelName = "Arithmetic_Add"
                
            case .DivideByConstant:
                if KernelSuffix.isEmpty
                {
                    return Buffer.first!
                }
                KernelName = "Arithmetic_Divide" + KernelSuffix
                return ConstantFilter(Buffer, Operation: .DivideByConstant, KernelName, Options)
                
            case .Mean:
                if Buffer.count < 2
                {
                    Debug.Print("Arithmetic mean specified but only one buffer passed.")
                    return Buffer.first!
                }
                if Buffer.count > 10
                {
                    Debug.Print("Too many buffers for arithmetic mean - must be from 2 to 10. \(Buffer.count) passed")
                    return Buffer.first!
                }
                KernelName = "Arithmetic_Mean\(Buffer.count)"
                
            case .MultiplyConstant:
                if KernelSuffix.isEmpty
                {
                    return Buffer.first!
                }
                KernelName = "Arithmetic_Multiply" + KernelSuffix
                return ConstantFilter(Buffer, Operation: .MultiplyConstant, KernelName, Options)
                
            case .NOP:
                return Buffer.first!
                
            case .SubtractConstant:
                if KernelSuffix.isEmpty
                {
                    return Buffer.first!
                }
                KernelName = "Arithmetic_SubtractConstant" + KernelSuffix
                return ConstantFilter(Buffer, Operation: .SubtractConstant, KernelName, Options)
                
            case .SubtractFromAccumulator:
                KernelName = "Arithmetic_Subtract"
                
            case .Greatest:
                return Buffer.first!
                
            case .Least:
                return Buffer.first!
        }
        
        return Buffer.first!
    }
    
    func ConstantFilter(_ Buffer: [CVPixelBuffer], Operation: ArithmeticOperations,
                        _ KernelName: String, _ Options: [FilterOptions: Any]) -> CVPixelBuffer
    {
        print("Arithmetic kernel: \(KernelName)")
        let DefaultLibrary = MetalDevice?.makeDefaultLibrary()
        let KernelFunction = DefaultLibrary?.makeFunction(name: KernelName)
        do
        {
            ComputePipelineState = try MetalDevice?.makeComputePipelineState(function: KernelFunction!)
        }
        catch
        {
            Debug.FatalError("Unable to create pipeline state in ConstantFilter[\(KernelName)]: \(error.localizedDescription)")
        }

        let Parameter = ArithmeticConstantParameters(NormalClamp: simd_bool(Options[.ArithmeticClamp] as! Bool),
                                                     r: simd_float1(Options[.RedValue] as! Double),
                                                     g: simd_float1(Options[.GreenValue] as! Double),
                                                     b: simd_float1(Options[.BlueValue] as! Double),
                                                     a: simd_float1(Options[.AlphaValue] as! Double),
                                                     UseRed: simd_bool(Options[.ArithmeticUseChannelR] as! Bool),
                                                     UseGreen: simd_bool(Options[.ArithmeticUseChannelG] as! Bool),
                                                     UseBlue: simd_bool(Options[.ArithmeticUseChannelB] as! Bool),
                                                     UseAlpha: simd_bool(Options[.ArithmeticUseChannelA] as! Bool))
        if Operation == .DivideByConstant
        {
            // If the user wants us to divide by zero, return the original buffer unchanged.
            if Parameter.UseRed && Parameter.r == 0
            {
                return Buffer.first!
            }
            if Parameter.UseGreen && Parameter.g == 0
            {
                return Buffer.first!
            }
            if Parameter.UseBlue && Parameter.b == 0
            {
                return Buffer.first!
            }
            if Parameter.UseAlpha && Parameter.a == 0
            {
                return Buffer.first!
            }
        }
        let Parameters = [Parameter]
        ParameterBuffer = MetalDevice!.makeBuffer(length: MemoryLayout<ArithmeticConstantParameters>.stride,
                                                  options: [])
        memcpy(ParameterBuffer.contents(), Parameters, MemoryLayout<ArithmeticConstantParameters>.stride)
        
        super.CreateBufferPool(Source: CIImage(cvPixelBuffer: Buffer.first!), From: Buffer.first!)
        var NewPixelBuffer: CVPixelBuffer? = nil
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, super.BasePool!, &NewPixelBuffer)

        guard let OutputBuffer = NewPixelBuffer else
        {
            Debug.FatalError("Error creating textures for ConstantFilter[\(KernelName)].")
        }
        
        guard let InputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: Buffer.first!, TextureFormat: .bgra8Unorm),
              let OutputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: OutputBuffer, TextureFormat: .bgra8Unorm) else
        {
            Debug.FatalError("Error creating textures in ConstantFilter[\(KernelName)].")
        }
        
        guard let CommandQ = CommandQueue,
              let CommandBuffer = CommandQ.makeCommandBuffer(),
              let CommandEncoder = CommandBuffer.makeComputeCommandEncoder() else
        {
            Debug.FatalError("Error creating Metal command queue.")
        }
        
        CommandEncoder.label = "Arithmetic Kernel \(KernelName)"
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
    
    /// Reset the filter's settings.
    static func ResetFilter()
    {

    }
}

enum ArithmeticOperations: Int
{
    case NOP = 0
    case AddConstant = 1
    case AddToAccumulator = 2
    case SubtractConstant = 3
    case SubtractFromAccumulator = 4
    case MultiplyConstant = 5
    case DivideByConstant = 6
    case Mean = 7
    case Greatest = 8
    case Least = 9
}
