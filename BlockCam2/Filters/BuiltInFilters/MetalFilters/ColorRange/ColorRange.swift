//
//  ColorRange.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/29/21.
//

import Foundation
import UIKit
import CoreMedia
import CoreVideo
import MetalKit

class ColorRange: MetalFilterParent, BuiltInFilterProtocol
{
    // MARK: - Required by BuiltInFilterProtocol.
    
    static var FilterType: BuiltInFilters = .ColorRange
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
        Debug.Print("Metal kernel function ColorRange initialized")
        let DefaultLibrary = MetalDevice?.makeDefaultLibrary()
        let KernelFunction = DefaultLibrary?.makeFunction(name: "ColorRange")
        do
        {
            ComputePipelineState = try MetalDevice?.makeComputePipelineState(function: KernelFunction!)
        }
        catch
        {
            print("Unable to create pipeline state in ColorRange: \(error.localizedDescription)")
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
            Debug.FatalError("LocalBufferPool is nil in ColorRange.Initialize.")
        }
        InputFormatDescription = FormatDescription
        Initialized = true
        var MetalTextureCache: CVMetalTextureCache? = nil
        guard CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, MetalDevice!, nil, &MetalTextureCache) == kCVReturnSuccess else
        {
            Debug.FatalError("Unable to allocate texture cache in ColorRange.")
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
            Debug.FatalError("ColorRange not initialized.")
        }
        objc_sync_enter(AccessLock)
        defer{objc_sync_exit(AccessLock)}
        
        let Parameter = ColorRangeParameters(RangeStart: simd_float1(Options[.StartRange] as! Double),
                                             RangeEnd: simd_float1(Options[.EndRange] as! Double), 
                                             InvertRange: simd_bool(Options[.Invert] as! Bool),
                                             NonRangeAction: simd_uint1(Options[.IntCommand] as! Int),
                                             NonRangeColor: (Options[.NonRangeColor] as! UIColor).ToFloat4())
        let Parameters = [Parameter]
        ParameterBuffer = MetalDevice!.makeBuffer(length: MemoryLayout<ColorRangeParameters>.stride,
                                                  options: [])
        memcpy(ParameterBuffer.contents(), Parameters, MemoryLayout<ColorRangeParameters>.stride)
        
        super.CreateBufferPool(Source: CIImage(cvPixelBuffer: Buffer.first!), From: Buffer.first!)
        var NewPixelBuffer: CVPixelBuffer? = nil
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, super.BasePool!, &NewPixelBuffer)

        guard let OutputBuffer = NewPixelBuffer else
        {
            Debug.FatalError("Error creating textures for ColorRange.")
        }
        
        guard let InputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: Buffer.first!, TextureFormat: .bgra8Unorm) else
        {
            Debug.FatalError("Error creating input texture in ColorRange.")
        }
        guard let OutputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: OutputBuffer, TextureFormat: .bgra8Unorm) else
        {
            Debug.FatalError("Error creating output texture in ColorRange.")
        }
        
        guard let CommandQ = CommandQueue,
              let CommandBuffer = CommandQ.makeCommandBuffer(),
              let CommandEncoder = CommandBuffer.makeComputeCommandEncoder() else
        {
            Debug.FatalError("Error creating Metal command queue.")
        }
        
        CommandEncoder.label = "ColorRange Kernel"
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
