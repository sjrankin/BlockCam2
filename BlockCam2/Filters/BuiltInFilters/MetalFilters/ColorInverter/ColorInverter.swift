//
//  ColorInverter.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/15/21.
//

import Foundation
import UIKit
import CoreMedia
import CoreVideo
import MetalKit

class ColorInverter:  MetalFilterParent, BuiltInFilterProtocol
{
    // MARK: - Required by BuiltInFilterProtocol.
    
    static var FilterType: BuiltInFilters = .ColorMap
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
        let KernelFunction = DefaultLibrary?.makeFunction(name: "ColorInverter")
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
            print("LocalBufferPool is nil in ColorInverter.Initialize.")
            return
        }
        InputFormatDescription = FormatDescription
        Initialized = true
        var MetalTextureCache: CVMetalTextureCache? = nil
        guard CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, MetalDevice!, nil, &MetalTextureCache) == kCVReturnSuccess else
        {
            fatalError("Unable to allocate texture cache in ColorInverter.")
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
        
        if !Initialized
        {
            Debug.FatalError("ColorInverter not initialized at Render(CVPixelBuffer) call.")
        }
        
        let Start = CACurrentMediaTime()
        let Colorspace = Options[.CIColorSpace] as? Int ?? 0
        let Invert1 = Options[.CIInvert1] as? Bool ?? false
        let Invert2 = Options[.CIInvert2] as? Bool ?? false
        let Invert3 = Options[.CIInvert3] as? Bool ?? false
        let Invert4 = Options[.CIInvert4] as? Bool ?? false
        let EnableThreshold1 = Options[.CIEnableThreshold1] as? Bool ?? false
        let EnableThreshold2 = Options[.CIEnableThreshold2] as? Bool ?? false
        let EnableThreshold3 = Options[.CIEnableThreshold3] as? Bool ?? false
        let EnableThreshold4 = Options[.CIEnableThreshold4] as? Bool ?? false
        let Threshold1 = Options[.CIThreshold1] as? Double ?? 0.5
        let Threshold2 = Options[.CIThreshold2] as? Double ?? 0.5
        let Threshold3 = Options[.CIThreshold3] as? Double ?? 0.5
        let Threshold4 = Options[.CIThreshold4] as? Double ?? 0.5
        let GreaterInvert1 = Options[.CIInvert1IfGreater] as? Bool ?? false
        let GreaterInvert2 = Options[.CIInvert2IfGreater] as? Bool ?? false
        let GreaterInvert3 = Options[.CIInvert3IfGreater] as? Bool ?? false
        let GreaterInvert4 = Options[.CIInvert4IfGreater] as? Bool ?? false
        let InvertAlpha = Options[.CIInvertAlpha] as? Bool ?? false
        let EnableAlphaThreshold = Options[.CIInvertAlphaThreshold] as? Bool ?? false
        let AlphaThreshold = Options[.CIAlphaThreshold] as? Double ?? 0.5
        let AlphaGreaterInvert = Options[.CIAlphaInvertIfGreater] as? Bool ?? false

        let Parameter = ColorInverterParameters(Colorspace: simd_uint1(Colorspace),
                                                InvertChannel1: Invert1,
                                                InvertChannel2: Invert2,
                                                InvertChannel3: Invert3,
                                                InvertChannel4: Invert4,
                                                EnableChannel1Threshold: EnableThreshold1,
                                                EnableChannel2Threshold: EnableThreshold2,
                                                EnableChannel3Threshold: EnableThreshold3,
                                                EnableChannel4Threshold: EnableThreshold4,
                                                Channel1Threshold: simd_float1(Threshold1),
                                                Channel2Threshold: simd_float1(Threshold2),
                                                Channel3Threshold: simd_float1(Threshold3),
                                                Channel4Threshold: simd_float1(Threshold4),
                                                Channel1InvertIfGreater: GreaterInvert1,
                                                Channel2InvertIfGreater: GreaterInvert2,
                                                Channel3InvertIfGreater: GreaterInvert3,
                                                Channel4InvertIfGreater: GreaterInvert4,
                                                InvertAlpha: InvertAlpha,
                                                EnableAlphaThreshold: EnableAlphaThreshold,
                                                AlphaThreshold: simd_float1(AlphaThreshold),
                                                AlphaInvertIfGreater: AlphaGreaterInvert)
        let Parameters = [Parameter]
        ParameterBuffer = MetalDevice!.makeBuffer(length: MemoryLayout<ColorInverterParameters>.stride, options: [])
        memcpy(ParameterBuffer.contents(), Parameters, MemoryLayout<ColorInverterParameters>.stride)
        
        super.CreateBufferPool(Source: CIImage(cvPixelBuffer: Buffer.first!), From: Buffer.first!)
        var NewPixelBuffer: CVPixelBuffer? = nil
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, super.BasePool!, &NewPixelBuffer)
        guard var OutputBuffer = NewPixelBuffer else
        {
            fatalError("Error creation textures for ColorInverter.")
        }
        
        guard let InputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: Buffer.first!, TextureFormat: .bgra8Unorm) else
        {
            Debug.FatalError("Error creating textures in ColorInverter.")
        }
        
        guard let OutputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: OutputBuffer, TextureFormat: .bgra8Unorm) else
        {
            Debug.FatalError("Error creating textures in ColorInverter.")
        }
        
        guard let CommandQ = CommandQueue,
              let CommandBuffer = CommandQ.makeCommandBuffer(),
              let CommandEncoder = CommandBuffer.makeComputeCommandEncoder() else
        {
            Debug.FatalError("Error creating Metal command queue.")
        }
        
        CommandEncoder.label = "Color Inverter Kernel"
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

        return OutputBuffer
    }

    static func ResetFilter()
    {
        Settings.SetInt(.ColorInverterColorSpace,
                        Settings.SettingDefaults[.ColorInverterColorSpace] as! Int)
        
        Settings.SetBool(.ColorInverterInvertChannel1,
                         Settings.SettingDefaults[.ColorInverterInvertChannel1] as! Bool)
        Settings.SetBool(.ColorInverterInvertChannel2,
                         Settings.SettingDefaults[.ColorInverterInvertChannel2] as! Bool)
        Settings.SetBool(.ColorInverterInvertChannel3,
                         Settings.SettingDefaults[.ColorInverterInvertChannel3] as! Bool)
        Settings.SetBool(.ColorInverterInvertChannel4,
                         Settings.SettingDefaults[.ColorInverterInvertChannel4] as! Bool)
        
        Settings.SetBool(.ColorInverterEnableChannel1Threshold,
                         Settings.SettingDefaults[.ColorInverterEnableChannel1Threshold] as! Bool)
        Settings.SetBool(.ColorInverterEnableChannel2Threshold,
                         Settings.SettingDefaults[.ColorInverterEnableChannel2Threshold] as! Bool)
        Settings.SetBool(.ColorInverterEnableChannel3Threshold,
                         Settings.SettingDefaults[.ColorInverterEnableChannel3Threshold] as! Bool)
        Settings.SetBool(.ColorInverterEnableChannel4Threshold,
                         Settings.SettingDefaults[.ColorInverterEnableChannel4Threshold] as! Bool)
        
        Settings.SetBool(.ColorInverterInvertChannel1IfGreater,
                         Settings.SettingDefaults[.ColorInverterInvertChannel1IfGreater] as! Bool)
        Settings.SetBool(.ColorInverterInvertChannel2IfGreater,
                         Settings.SettingDefaults[.ColorInverterInvertChannel2IfGreater] as! Bool)
        Settings.SetBool(.ColorInverterInvertChannel3IfGreater,
                         Settings.SettingDefaults[.ColorInverterInvertChannel3IfGreater] as! Bool)
        Settings.SetBool(.ColorInverterInvertChannel4IfGreater,
                         Settings.SettingDefaults[.ColorInverterInvertChannel4IfGreater] as! Bool)
        
        Settings.SetDouble(.ColorInverterChannel1Threshold,
                         Settings.SettingDefaults[.ColorInverterChannel1Threshold] as! Double)
        Settings.SetDouble(.ColorInverterChannel2Threshold,
                         Settings.SettingDefaults[.ColorInverterChannel2Threshold] as! Double)
        Settings.SetDouble(.ColorInverterChannel3Threshold,
                         Settings.SettingDefaults[.ColorInverterChannel3Threshold] as! Double)
        Settings.SetDouble(.ColorInverterChannel4Threshold,
                         Settings.SettingDefaults[.ColorInverterChannel4Threshold] as! Double)
        
        Settings.SetBool(.ColorInverterInvertAlpha,
                         Settings.SettingDefaults[.ColorInverterInvertAlpha] as! Bool)
        Settings.SetBool(.ColorInverterEnableAlphaThreshold,
                         Settings.SettingDefaults[.ColorInverterEnableAlphaThreshold] as! Bool)
        Settings.SetDouble(.ColorInverterAlphaThreshold,
                           Settings.SettingDefaults[.ColorInverterAlphaThreshold] as! Double)
        Settings.SetBool(.ColorInverterInvertAlphaIfGreater,
                         Settings.SettingDefaults[.ColorInverterInvertAlphaIfGreater] as! Bool)
    }
}
