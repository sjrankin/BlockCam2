//
//  ChannelMixer.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/16/21.
//

import Foundation
import UIKit
import CoreMedia
import CoreVideo
import CoreImage
import simd

class ChannelMixer: MetalFilterParent, BuiltInFilterProtocol
{
    // MARK: - Required by BuiltInFilterProtocol.
    
    static var FilterType: BuiltInFilters = .ChannelMixer
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
            print("LocalBufferPool is nil in ChannelMixer.Initialize.")
            return
        }
        InputFormatDescription = FormatDescription
        Initialized = true
        var MetalTextureCache: CVMetalTextureCache? = nil
        guard CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, MetalDevice!, nil, &MetalTextureCache) == kCVReturnSuccess else
        {
            fatalError("Unable to allocate texture cache in ChannelMixer.")
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
            fatalError("ChannelMixer not initialized at Render(CVPixelBuffer) call.")
        }
        
        let DefaultLibrary = MetalDevice?.makeDefaultLibrary()
        let KernelFunction = DefaultLibrary?.makeFunction(name: "HSBSwizzling")
        do
        {
            ComputePipelineState = try MetalDevice?.makeComputePipelineState(function: KernelFunction!)
        }
        catch
        {
            print("Unable to create pipeline state: \(error.localizedDescription)")
        }
        
        let C1 = Options[.Channel1] as? Int ?? 0
        let C2 = Options[.Channel2] as? Int ?? 1
        let C3 = Options[.Channel3] as? Int ?? 2
        var IsHSB = false
        if ChannelIsInHSB(Channel: C1) || ChannelIsInHSB(Channel: C2) || ChannelIsInHSB(Channel: C3)
        {
            IsHSB = true
        }
        var IsCMYK = false
        if ChannelIsInCMYK(Channel: C1) || ChannelIsInCMYK(Channel: C2) || ChannelIsInCMYK(Channel: C3)
        {
            IsCMYK = true
        }
        let InvertRed = Options[.InvertChannel1] as? Bool ?? false
        let InvertGreen = Options[.InvertChannel2] as? Bool ?? false
        let InvertBlue = Options[.InvertChannel3] as? Bool ?? false
        let Parameter = ChannelSwizzles(Channel1: simd_int1(C1), Channel2: simd_int1(C2), Channel3: simd_int1(C3),
                                        HasHSB: simd_bool(IsHSB), HasCMYK: simd_bool(IsCMYK),
                                        InvertRed: simd_bool(InvertRed), InvertGreen: simd_bool(InvertGreen),
                                        InvertBlue: simd_bool(InvertBlue))
        let Parameters = [Parameter]
        ParameterBuffer = MetalDevice!.makeBuffer(length: MemoryLayout<ChannelSwizzles>.stride, options: [])
        memcpy(ParameterBuffer.contents(), Parameters, MemoryLayout<ChannelSwizzles>.stride)
        
        super.CreateBufferPool(Source: CIImage(cvPixelBuffer: Buffer.first!), From: Buffer.first!)
        var NewPixelBuffer: CVPixelBuffer? = nil
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, super.BasePool!, &NewPixelBuffer)
        guard let OutputBuffer = NewPixelBuffer else
        {
            Debug.FatalError("Error creation textures for ChannelMixer.")
        }
        
        guard let InputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: Buffer.first!, TextureFormat: .bgra8Unorm) else
        {
            Debug.FatalError("Error creating textures in ChannelMixer.")
        }
        
        guard let OutputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: OutputBuffer, TextureFormat: .bgra8Unorm) else
        {
            Debug.FatalError("Error creating textures in ChannelMixer.")
        }
        
        guard let CommandQ = CommandQueue,
              let CommandBuffer = CommandQ.makeCommandBuffer(),
              let CommandEncoder = CommandBuffer.makeComputeCommandEncoder() else
        {
            Debug.FatalError("Error creating Metal command queue.")
        }
        
        CommandEncoder.label = "Channel Mixer"
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
    
    func ChannelIsInHSB(Channel: Int) -> Bool
    {
        return Channel >= Channels.Hue.rawValue && Channel <= Channels.Brightness.rawValue
    }
    
    func ChannelIsInCMYK(Channel: Int) -> Bool
    {
        return Channel >= Channels.Cyan.rawValue && Channel <= Channels.Black.rawValue
    }
    
    static func ResetFilter()
    {
        Settings.SetInt(.ChannelMixerChannel1, Settings.SettingDefaults[.ChannelMixerChannel1] as! Int)
        Settings.SetInt(.ChannelMixerChannel2, Settings.SettingDefaults[.ChannelMixerChannel2] as! Int)
        Settings.SetInt(.ChannelMixerChannel3, Settings.SettingDefaults[.ChannelMixerChannel3] as! Int)
        Settings.SetBool(.ChannelMixerInvertChannel1,
                         Settings.SettingDefaults[.ChannelMixerInvertChannel1] as! Bool)
        Settings.SetBool(.ChannelMixerInvertChannel2,
                         Settings.SettingDefaults[.ChannelMixerInvertChannel2] as! Bool)
        Settings.SetBool(.ChannelMixerInvertChannel3,
                         Settings.SettingDefaults[.ChannelMixerInvertChannel3] as! Bool)
    }
    
    static let ChannelNames: [Int: String] =
    [
        Channels.Red.rawValue: "Red",
        Channels.Green.rawValue: "Green",
        Channels.Blue.rawValue: "Blue",
        Channels.Hue.rawValue: "Hue",
        Channels.Saturation.rawValue: "Saturation",
        Channels.Brightness.rawValue: "Brightness",
        Channels.Cyan.rawValue: "Cyan",
        Channels.Magenta.rawValue: "Magenta",
        Channels.Yellow.rawValue: "Yellow",
        Channels.Black.rawValue: "Black"
    ]
}

/// Color channel defintions.
/// - Red: Red channel.
/// - Green: Green channel.
/// - Blue: Blue channel.
/// - Hue: Hue value from HSB color space.
/// - Saturation: Saturation value from HSB color space.
/// - Brightness: Brightness value from HSB color space.
/// - Cyan: Cyan channel from CMYK color space.
/// - Magenta: Magenta channel from CMYK color space.
/// - Yellow: Yellow channel from CMYK color space.
/// - Black: Black channel from CMYK color space.
enum Channels: Int
{
    case Red = 0
    case Green = 1
    case Blue = 2
    case Hue = 3
    case Saturation = 4
    case Brightness = 5
    case Cyan = 6
    case Magenta = 7
    case Yellow = 8
    case Black = 9
}

