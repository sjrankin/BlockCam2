//
//  ConditionalSilhouette.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/15/21.
//

import Foundation
import UIKit
import CoreMedia
import CoreVideo
import MetalKit

class ConditionalSilhouette: MetalFilterParent, BuiltInFilterProtocol
{
    // MARK: - Required by BuiltInFilterProtocol.
    
    static var FilterType: BuiltInFilters = .ConditionalSilhouette
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
        let KernelFunction = DefaultLibrary?.makeFunction(name: "ConditionalSilhouette")
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
        (BufferPool, _, OutputFormatDescription) = CreateBufferPool(From: FormatDescription, BufferCountHint: BufferCountHint)
        if BufferPool == nil
        {
            print("BufferPool nil in ConditionalSilhouette.Initialize.")
            return
        }
        InputFormatDescription = FormatDescription
        
        Initialized = true
        
        var MetalTextureCache: CVMetalTextureCache? = nil
        if CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, MetalDevice!, nil, &MetalTextureCache) != kCVReturnSuccess
        {
            fatalError("Unable to allocation texture cache in ConditionalSilhouette.")
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
            Debug.FatalError("ConditionalSilhouette not initialized at Render(CVPixelBuffer) call.")
        }
        
        let Trigger = Options[.CSTrigger] as? Int ?? 0
        let HueThreshold = Options[.CSHueThreshold] as? Double ?? 0.5
        let HueRange = Options[.CSHueRange] as? Double ?? 0.3
        let SatThreshold = Options[.CSSatThreshold] as? Double ?? 0.5
        let SatRange = Options[.CSSatRange] as? Double ?? 0.3
        let BriThreshold = Options[.CSBriThreshold] as? Double ?? 0.5
        let BriRange = Options[.CSBriRange] as? Double ?? 0.3
        let GreaterThan = Options[.CSGreaterThan] as? Bool ?? false
        let SColor = Options[.CSColor] as? UIColor ?? UIColor.black
        let Parameter = SilhouetteParameters(Trigger: simd_uint1(Trigger),
                                             HueThreshold: simd_float1(HueThreshold),
                                             HueRange: simd_float1(HueRange),
                                             SaturationThreshold: simd_float1(SatThreshold),
                                             SaturationRange: simd_float1(SatRange),
                                             BrightnessThreshold: simd_float1(BriThreshold),
                                             BrightnessRange: simd_float1(BriRange),
                                             GreaterThan: GreaterThan,
                                             SilhouetteColor: SColor.ToFloat4())
        let Parameters = [Parameter]
        ParameterBuffer = MetalDevice!.makeBuffer(length: MemoryLayout<SilhouetteParameters>.stride, options: [])
        memcpy(ParameterBuffer.contents(), Parameters, MemoryLayout<SilhouetteParameters>.stride)
        
        super.CreateBufferPool(Source: CIImage(cvPixelBuffer: Buffer.first!), From: Buffer.first!)
        var NewPixelBuffer: CVPixelBuffer? = nil
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, super.BasePool!, &NewPixelBuffer)
        guard let OutputBuffer = NewPixelBuffer else
        {
            Debug.FatalError("Error creation textures for ConditionalSilhouette.")
        }
        
        guard let InputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: Buffer.first!, TextureFormat: .bgra8Unorm) else
        {
            Debug.FatalError("Error creating textures in ConditionalSilhouette.")
        }
        
        guard let OutputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: OutputBuffer, TextureFormat: .bgra8Unorm) else
        {
            Debug.FatalError("Error creating textures in ConditionalSilhouette.")
        }
        
        guard let CommandQ = CommandQueue,
              let CommandBuffer = CommandQ.makeCommandBuffer(),
              let CommandEncoder = CommandBuffer.makeComputeCommandEncoder() else
        {
            Debug.FatalError("Error creating Metal command queue.")
        }
        
        CommandEncoder.label = "Conditional Silhouette Kernel"
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
        Settings.SetDouble(.ColorInverterChannel1Threshold,
                         Settings.SettingDefaults[.ColorInverterChannel1Threshold] as! Double)
        Settings.SetDouble(.ColorInverterChannel2Threshold,
                         Settings.SettingDefaults[.ColorInverterChannel2Threshold] as! Double)
        Settings.SetDouble(.ColorInverterChannel3Threshold,
                         Settings.SettingDefaults[.ColorInverterChannel3Threshold] as! Double)
        Settings.SetDouble(.ColorInverterChannel4Threshold,
                         Settings.SettingDefaults[.ColorInverterChannel4Threshold] as! Double)
        Settings.SetBool(.ColorInverterInvertChannel1IfGreater,
                         Settings.SettingDefaults[.ColorInverterInvertChannel1IfGreater] as! Bool)
        Settings.SetBool(.ColorInverterInvertChannel2IfGreater,
                         Settings.SettingDefaults[.ColorInverterInvertChannel2IfGreater] as! Bool)
        Settings.SetBool(.ColorInverterInvertChannel3IfGreater,
                         Settings.SettingDefaults[.ColorInverterInvertChannel3IfGreater] as! Bool)
        Settings.SetBool(.ColorInverterInvertChannel4IfGreater,
                         Settings.SettingDefaults[.ColorInverterInvertChannel4IfGreater] as! Bool)
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
