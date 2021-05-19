//
//  SolarizeRGB.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/17/21.
//

import Foundation
import UIKit
import CoreMedia
import CoreVideo
import MetalKit

class SolarizeRGB: MetalFilterParent, BuiltInFilterProtocol
{
    // MARK: - Required by BuiltInFilterProtocol.
    
    static var FilterType: BuiltInFilters = .SolarizeRGB
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
        let KernelFunction = DefaultLibrary?.makeFunction(name: "SolarizeRGB")
        do
        {
            ComputePipelineState = try MetalDevice?.makeComputePipelineState(function: KernelFunction!)
        }
        catch
        {
            print("Unable to create pipeline state: \(error.localizedDescription)")
        }
    }
    
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
            print("LocalBufferPool is nil in SolarizeRGB.Initialize.")
            return
        }
        InputFormatDescription = FormatDescription
        Initialized = true
        var MetalTextureCache: CVMetalTextureCache? = nil
        guard CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, MetalDevice!, nil, &MetalTextureCache) == kCVReturnSuccess else
        {
            fatalError("Unable to allocate texture cache in SolarizeRGB.")
        }
        TextureCache = MetalTextureCache
    }
    
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
    
    var AccessLock = NSObject()
    
    func RunFilter(_ Buffer: [CVPixelBuffer], _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace, Options: [FilterOptions: Any]) -> CVPixelBuffer
    {
        objc_sync_enter(AccessLock)
        defer{objc_sync_exit(AccessLock)}
        
        if !Initialized
        {
            Debug.FatalError("SolarizeRGB not initialized at Render(CVPixelBuffer) call.")
        }
        
        let How = Options[.IntCommand] as! Int
        let IfGreater = Options[.IsGreater] as! Bool
        let Threshold = Options[.Threshold] as! Double
        let OnlyChannel = Options[.OnlyChannel] as! Bool 
        let Parameter = SolarizeRGBParameters(SolarizeHow: simd_uint1(How),
                                              Threshold: simd_float1(Threshold),
                                              SolarizeIfGreater: simd_bool(IfGreater),
                                              OnlyChannel: simd_bool(OnlyChannel))
        let Parameters = [Parameter]
        ParameterBuffer = MetalDevice!.makeBuffer(length: MemoryLayout<SolarizeRGBParameters>.stride, options: [])
        memcpy(ParameterBuffer.contents(), Parameters, MemoryLayout<SolarizeRGBParameters>.stride)
        
        super.CreateBufferPool(Source: CIImage(cvPixelBuffer: Buffer.first!), From: Buffer.first!)
        var NewPixelBuffer: CVPixelBuffer? = nil
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, super.BasePool!, &NewPixelBuffer)
        guard let OutputBuffer = NewPixelBuffer else
        {
            fatalError("Error creation textures for SolarizeRGB.")
        }
        
        guard let InputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: Buffer.first!, TextureFormat: .bgra8Unorm) else
        {
            Debug.FatalError("Error creating input texture in SolarizeRGB.")
        }
        
        guard let OutputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: OutputBuffer, TextureFormat: .bgra8Unorm) else
        {
            Debug.FatalError("Error creating output texture in SolarizeRGB.")
        }
        
        guard let CommandQ = CommandQueue,
              let CommandBuffer = CommandQ.makeCommandBuffer(),
              let CommandEncoder = CommandBuffer.makeComputeCommandEncoder() else
        {
            Debug.FatalError("Error creating Metal command queue.")
        }
        
        CommandEncoder.label = "SolarizeRGB Kernel"
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
        Settings.SetInt(.SolarizeHow, Settings.SettingDefaults[.SolarizeHow] as! Int)
        Settings.SetBool(.SolarizeIfGreater, Settings.SettingDefaults[.SolarizeIfGreater] as! Bool)
        Settings.SetDouble(.SolarizeThresholdLow,
                           Settings.SettingDefaults[.SolarizeThresholdLow] as! Double)
        Settings.SetDouble(.SolarizeThresholdHigh,
                           Settings.SettingDefaults[.SolarizeThresholdHigh] as! Double)
        Settings.SetDouble(.SolarizeLowHue,
                           Settings.SettingDefaults[.SolarizeLowHue] as! Double)
        Settings.SetDouble(.SolarizeHighHue,
                           Settings.SettingDefaults[.SolarizeHighHue] as! Double)
        Settings.SetDouble(.SolarizeBrightnessThresholdLow,
                           Settings.SettingDefaults[.SolarizeBrightnessThresholdLow] as! Double)
        Settings.SetDouble(.SolarizeBrightnessThresholdHigh,
                           Settings.SettingDefaults[.SolarizeBrightnessThresholdHigh] as! Double)
        Settings.SetDouble(.SolarizeSaturationThresholdLow,
                           Settings.SettingDefaults[.SolarizeSaturationThresholdLow] as! Double)
        Settings.SetDouble(.SolarizeSaturationThresholdHigh,
                           Settings.SettingDefaults[.SolarizeSaturationThresholdHigh] as! Double)
    }
}
