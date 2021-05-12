//
//  HSB.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/6/21.
//

import Foundation
import UIKit
import CoreMedia
import CoreVideo
import MetalKit

class HSB: MetalFilterParent, BuiltInFilterProtocol
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
    
    override required init()
    {
        print("Metal kernel function HSB initialized")
        let DefaultLibrary = MetalDevice?.makeDefaultLibrary()
        let KernelFunction = DefaultLibrary?.makeFunction(name: "HSB")
        do
        {
            ComputePipelineState = try MetalDevice?.makeComputePipelineState(function: KernelFunction!)
        }
        catch
        {
            print("Unable to create pipeline state in HSB: \(error.localizedDescription)")
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
            print("LocalBufferPool is nil in HSB.Initialize.")
            return
        }
        InputFormatDescription = FormatDescription
        Initialized = true
        var MetalTextureCache: CVMetalTextureCache? = nil
        guard CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, MetalDevice!, nil, &MetalTextureCache) == kCVReturnSuccess else
        {
            fatalError("Unable to allocate texture cache in HSB.")
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
            fatalError("HSB not initialized.")
        }
        objc_sync_enter(AccessLock)
        defer{objc_sync_exit(AccessLock)}
        
        let Parameter = HSBParameters(ChangeHue: simd_bool(Options[.ChangeHue] as? Bool ?? true),
                                      Hue: simd_float1(Options[.Hue] as? Double ?? 1.0),
                                      ChangeSaturation: simd_bool(Options[.ChangeSaturation] as? Bool ?? true),
                                      Saturation: simd_float1(Options[.Saturation] as? Double ?? 1.0),
                                      ChangeBrightness: simd_bool(Options[.ChangeBrightness] as? Bool ?? true),
                                      Brightness: simd_float1(Options[.Brightness] as? Double ?? 1.0))
        let Parameters = [Parameter]
        ParameterBuffer = MetalDevice!.makeBuffer(length: MemoryLayout<HSBParameters>.stride,
                                                  options: [])
        memcpy(ParameterBuffer.contents(), Parameters, MemoryLayout<HSBParameters>.stride)
        
        #if true
        super.CreateBufferPool(Source: CIImage(cvPixelBuffer: Buffer.first!), From: Buffer.first!)
        var NewPixelBuffer: CVPixelBuffer? = nil
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, super.BasePool!, &NewPixelBuffer)
        #else
        guard let Format = FilterHelper.GetFormatDescription(From: Buffer.first!) else
        {
            fatalError("Error getting description of buffer in HSB.")
        }
        let ImageSize = CGSize(width: Int(Format.dimensions.width), height: Int(Format.dimensions.height))
        guard let LocalBufferPool = FilterHelper.CreateBufferPool(From: Format,
                                                                  BufferCountHint: 3,
                                                                  BufferSize: ImageSize) else
        {
            fatalError("Error creating local buffer pool in HSB.")
        }
        var NewPixelBuffer: CVPixelBuffer? = nil
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, LocalBufferPool, &NewPixelBuffer)
        #endif
        guard let OutputBuffer = NewPixelBuffer else
        {
            fatalError("Error creating textures for HSB.")
        }
        
        guard let InputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: Buffer.first!, TextureFormat: .bgra8Unorm),
              let OutputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: OutputBuffer, TextureFormat: .bgra8Unorm) else
        {
            fatalError("Error creating textures in HSB.")
        }
        
        guard let CommandQ = CommandQueue,
              let CommandBuffer = CommandQ.makeCommandBuffer(),
              let CommandEncoder = CommandBuffer.makeComputeCommandEncoder() else
        {
            fatalError("Error creating Metal command queue.")
        }
        
        CommandEncoder.label = "HSB Kernel"
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
        Settings.SetDouble(.HSBHueValue,
                          Settings.SettingDefaults[.HSBHueValue] as! Double)
        Settings.SetBool(.HSBChangeHue,
                          Settings.SettingDefaults[.HSBChangeHue] as! Bool)
        Settings.SetDouble(.HSBSaturationValue,
                           Settings.SettingDefaults[.HSBSaturationValue] as! Double)
        Settings.SetBool(.HSBChangeSaturation,
                         Settings.SettingDefaults[.HSBChangeSaturation] as! Bool)
        Settings.SetDouble(.HSBBrightnessValue,
                           Settings.SettingDefaults[.HSBBrightnessValue] as! Double)
        Settings.SetBool(.HSBChangeBrightness,
                         Settings.SettingDefaults[.HSBChangeBrightness] as! Bool)
    }
}
