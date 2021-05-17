//
//  ChannelMangler.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/15/21.
//

import Foundation
import UIKit
import CoreMedia
import CoreVideo
import MetalKit

class ChannelMangler:  MetalFilterParent, BuiltInFilterProtocol
{
    // MARK: - Required by BuiltInFilterProtocol.
    
    static var FilterType: BuiltInFilters = .ChannelMangler
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
        let KernelFunction = DefaultLibrary?.makeFunction(name: "ChannelMangler")
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
            print("LocalBufferPool is nil in ChannelMangler.Initialize.")
            return
        }
        InputFormatDescription = FormatDescription
        Initialized = true
        var MetalTextureCache: CVMetalTextureCache? = nil
        guard CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, MetalDevice!, nil, &MetalTextureCache) == kCVReturnSuccess else
        {
            fatalError("Unable to allocate texture cache in ChannelMangler.")
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
            fatalError("ChannelMangler not initialized at Render(CVPixelBuffer) call.")
        }
        
        let MangleAction = Options[.IntCommand] as? Int ?? 0
        let Parameter = ChannelManglerParameters(Action: simd_uint1(MangleAction))
        let Parameters = [Parameter]
        ParameterBuffer = MetalDevice!.makeBuffer(length: MemoryLayout<ChannelManglerParameters>.stride, options: [])
        memcpy(ParameterBuffer.contents(), Parameters, MemoryLayout<ChannelManglerParameters>.stride)
        
        super.CreateBufferPool(Source: CIImage(cvPixelBuffer: Buffer.first!), From: Buffer.first!)
        var NewPixelBuffer: CVPixelBuffer? = nil
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, super.BasePool!, &NewPixelBuffer)
        guard let OutputBuffer = NewPixelBuffer else
        {
            fatalError("Error creation textures for ChannelMangler.")
        }
        
        guard let InputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: Buffer.first!, TextureFormat: .bgra8Unorm) else
        {
            Debug.FatalError("Error creating textures in ChannelMangler.")
        }
        
        guard let OutputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: OutputBuffer, TextureFormat: .bgra8Unorm) else
        {
            Debug.FatalError("Error creating textures in ChannelMangler.")
        }
        
        let GradientColors = GradientManager.ResolveGradient("(Cyan)@(0.0),(Magenta)@(0.33),(Yellow)@(0.67),(Black)@(1.0)")
        var IGradient = [simd_float4](repeating: simd_float4(0.0, 0.0, 0.0, 1.0), count: 256)
        for index in 0 ... 255
        {
            let Color = GradientColors[index]
            IGradient[index] = simd_float4(Float(Color.r), Float(Color.g), Float(Color.b), 1.0)
        }
        let IGPtr = UnsafePointer(IGradient)
        let GradientBufferSize = MemoryLayout<simd_float4>.stride * 256
        let GradientBuffer = MetalDevice!.makeBuffer(bytes: IGPtr, length: GradientBufferSize, options: [])
        
        guard let CommandQ = CommandQueue,
              let CommandBuffer = CommandQ.makeCommandBuffer(),
              let CommandEncoder = CommandBuffer.makeComputeCommandEncoder() else
        {
            Debug.FatalError("Error creating Metal command queue.")
        }
        
        CommandEncoder.label = "Channel Mangler Kernel"
        CommandEncoder.setComputePipelineState(ComputePipelineState!)
        CommandEncoder.setTexture(InputTexture, index: 0)
        CommandEncoder.setTexture(OutputTexture, index: 1)
        CommandEncoder.setBuffer(ParameterBuffer, offset: 0, index: 0)
        CommandEncoder.setBuffer(GradientBuffer, offset: 0, index: 1)
        
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
        Settings.SetInt(.ConditionalSilhouetteTrigger,
                        Settings.SettingDefaults[.ConditionalSilhouetteTrigger] as! Int)
        Settings.SetDouble(.ConditionalSilhouetteHueThreshold,
                           Settings.SettingDefaults[.ConditionalSilhouetteHueThreshold] as! Double)
        Settings.SetDouble(.ConditionalSilhouetteHueRange,
                           Settings.SettingDefaults[.ConditionalSilhouetteHueRange] as! Double)
        Settings.SetDouble(.ConditionalSilhouetteSatThreshold,
                           Settings.SettingDefaults[.ConditionalSilhouetteSatThreshold] as! Double)
        Settings.SetDouble(.ConditionalSilhouetteSatRange,
                           Settings.SettingDefaults[.ConditionalSilhouetteSatRange] as! Double)
        Settings.SetDouble(.ConditionalSilhouetteBriThreshold,
                           Settings.SettingDefaults[.ConditionalSilhouetteBriThreshold] as! Double)
        Settings.SetDouble(.ConditionalSilhouetteBriRange,
                           Settings.SettingDefaults[.ConditionalSilhouetteBriRange] as! Double)
        Settings.SetBool(.ConditionalSilhouetteGreaterThan,
                         Settings.SettingDefaults[.ConditionalSilhouetteGreaterThan] as! Bool)
        Settings.SetColor(.ConditionalSilhouetteColor,
                          Settings.SettingDefaults[.ConditionalSilhouetteColor] as! UIColor)
    }
    
    static let MangleTypes: [Int: (Command: String, Description: String)] =
        [
            0: ("NOP", "No changes made to the image."),
            1: ("Channel Max Other", "Each channel's value becomes the maximum of the other two channels."),
            2: ("Channel Min Other", "Each channel's value becomes the minimum of the other two channels."),
            3: ("Channel + Mean Other", "Channel values become (channel value + Mean(other two channels)) / 2"),
            4: ("Max Channel Inverted", "The channel with the greatest value is inverted. The other two are used as is."),
            5: ("Min Channel Inverted", "The channel with the smallest value is inverted. The other two are used as is."),
            6: ("Transpose Red", "The red channel values is obtained from the transposed pixel."),
            7: ("Transpose Green", "The green channel values is obtained from the transposed pixel."),
            8: ("Transpose Blue", "The blue channel values is obtained from the transposed pixel."),
            9: ("Transpose Cyan", "The cyan channel values is obtained from the transposed pixel."),
            10: ("Transpose Magenta", "The magenta channel values is obtained from the transposed pixel."),
            11: ("Transpose Yellow", "The yellow channel values is obtained from the transposed pixel."),
            12: ("Transpose Black", "The black channel values is obtained from the transposed pixel."),
            13: ("Transpose Hue", "The hue channel values is obtained from the transposed pixel."),
            14: ("Transpose Saturation", "The saturation channel values is obtained from the transposed pixel."),
            15: ("Transpose Brightness", "The brightness channel values is obtained from the transposed pixel."),
            16: ("Ranged Hue", "The hue value is constrained to an equal range within 360°."),
            17: ("Ranged Saturation", "The saturation value is constrained to an equal range."),
            18: ("Ranged Brightness", "The brightness value is constrained to an equal range."),
            19: ("Red + X:8", "The red channel value is obtained 8 horizontal pixels to the right (and down if near the right edge)."),
            20: ("Green + X:8", "The green channel value is obtained 8 horizontal pixels to the right (and down if near the right edge)."),
            21: ("Blue + X:8", "The blue channel value is obtained 8 horizontal pixels to the right (and down if near the right edge)."),
            22: ("3x3 Red Mean", "The red channel is set to the mean of the 3x3 grid with the current pixel as the center."),
            23: ("3x3 Green Mean", "The green channel is set to the mean of the 3x3 grid with the current pixel as the center."),
            24: ("3x3 Blue Mean", "The blue channel is set to the mean of the 3x3 grid with the current pixel as the center."),
            25: ("Largest Mean Channel", "Each channel is set to the greatest mean value of the red, green, or blue channels."),
            26: ("Smallest Mean Channel", "Each channel is set to the smallest mean value of the red, green, or blue channels."),
            27: ("Mask with 0xfe", "Each channel value is converted to 0...255 then masked with 0xfe."),
            28: ("Mask with 0xfc", "Each channel value is converted to 0...255 then masked with 0xfc."),
            29: ("Mask with 0xf8", "Each channel value is converted to 0...255 then masked with 0xf8."),
            30: ("Mask with 0xf0", "Each channel value is converted to 0...255 then masked with 0xf0."),
            31: ("Mask with 0xe0", "Each channel value is converted to 0...255 then masked with 0xe0."),
            32: ("Mask with 0xc0", "Each channel value is converted to 0...255 then masked with 0xc0."),
            33: ("Mask with 0x80", "Each channel value is converted to 0...255 then masked with 0x80."),
            34: ("Compact Shift Low", "Each channel has all bits compressed such that there are no 0s, then shifted right."),
            35: ("Compact Shift High", "Each channel has all bits compressed such that there are no 0s, then shifted left."),
            36: ("Reverse Bits", "Each channe's bits are reversed."),
            37: ("Red xor Green Blue", "The green and blue channel values are xored with the red channel."),
            38: ("Green xor Red blue", "The red and blue channel values are xored with the green channel."),
            39: ("Blue xor Red Green", "The red and green channel values are xored with the blue channel."),
            40: ("Multi-Xored", "Each channel is xored with the xor of the other two channels."),
            41: ("Xor-Or", "Each channel is xored with the another channel ored with the third channel."),
            42: ("Xor-And", "Each channel is xored with the another channel anded with the third channel."),
            43: ("Quick & Dirty Hue Gradient", "A gradient is applied to the image base on hue."),
            44: ("Quick & Dirty Saturation Gradient", "A gradient is applied to the image base on saturation."),
            45: ("Quick & Dirty Brightness Gradient", "A gradient is applied to the image base on brightness."),
            46: ("Quick & Dirty Mean Gradient", "Takes the mean of each pixel and uses that value as an index into a gradient."),
        ]
}
