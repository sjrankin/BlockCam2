//
//  Filters.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/18/21.
//

import Foundation
import UIKit
import SceneKit
import AVFoundation
import CoreImage
import CoreServices
import AVKit
import Photos
import MobileCoreServices
import CoreMotion
import CoreMedia
import CoreVideo
import CoreImage.CIFilterBuiltins

/// Class that manages filters for live view and photo output.
class Filters
{
    /// Initialize filter.
    /// - Notes: If already initialized, control is returned immediately.
    public static func InitializeFilters()
    {
        if Initialized
        {
            return
        }
        let LastFilterName = Settings.GetString(.CurrentFilter, "")
        if let LastSaved = BuiltInFilters(rawValue: LastFilterName)
        {
            LastBuiltInFilterUsed = LastSaved
        }
        _Initialized = true
    }
    
    /// Holds the initialized flag.
    private static var _Initialized: Bool = false
    /// Get the initialized flag.
    public static var Initialized: Bool
    {
        get
        {
            return _Initialized
        }
    }
    
    /// Initialize the filter manager.
    /// - Parameter From: The format description for filtering images.
    /// - Parameter Caller: Used for debugging.
    public static func Initialize(From: CMFormatDescription, Caller: String)
    {
        let InputSubType = CMFormatDescriptionGetMediaSubType(From)
        if InputSubType != kCVPixelFormatType_32BGRA
        {
            fatalError("Invalid pixel buffer type \(InputSubType)")
        }
        
        let InputSize = CMVideoFormatDescriptionGetDimensions(From)
        var PixelBufferAttrs: [String: Any] =
            [
                kCVPixelBufferPixelFormatTypeKey as String: UInt(InputSubType),
                kCVPixelBufferWidthKey as String: Int(InputSize.width),
                kCVPixelBufferHeightKey as String: Int(InputSize.height),
                kCVPixelBufferIOSurfacePropertiesKey as String: [:]
            ]
        
        var GColorSpace = CGColorSpaceCreateDeviceRGB()
        if let FromEx = CMFormatDescriptionGetExtensions(From) as Dictionary?
        {
            let ColorPrimaries = FromEx[kCVImageBufferColorPrimariesKey]
            if let ColorPrimaries = ColorPrimaries
            {
                var ColorSpaceProps: [String: AnyObject] = [kCVImageBufferColorPrimariesKey as String: ColorPrimaries]
                if let YCbCrMatrix = FromEx[kCVImageBufferYCbCrMatrixKey]
                {
                    ColorSpaceProps[kCVImageBufferYCbCrMatrixKey as String] = YCbCrMatrix
                }
                if let XferFunc = FromEx[kCVImageBufferTransferFunctionKey]
                {
                    ColorSpaceProps[kCVImageBufferTransferFunctionKey as String] = XferFunc
                }
                PixelBufferAttrs[kCVBufferPropagatedAttachmentsKey as String] = ColorSpaceProps
            }
            if let CVColorSpace = FromEx[kCVImageBufferCGColorSpaceKey]
            {
                GColorSpace = CVColorSpace as! CGColorSpace
            }
            else
            {
                if (ColorPrimaries as? String) == (kCVImageBufferColorPrimaries_P3_D65 as String)
                {
                    GColorSpace = CGColorSpace(name: CGColorSpace.displayP3)!
                }
            }
        }
        ColorSpace = GColorSpace
        
        let PoolAttrs = [kCVPixelBufferPoolMinimumBufferCountKey as String: 3]
        var CVPixBufPool: CVPixelBufferPool?
        CVPixelBufferPoolCreate(kCFAllocatorDefault, PoolAttrs as NSDictionary?,
                                PixelBufferAttrs as NSDictionary?,
                                &CVPixBufPool)
        guard let WorkingBufferPool = CVPixBufPool else
        {
            fatalError("Allocation failure - could not allocate pixel buffer pool.")
        }
        
        PreAllocateBuffers(Pool: WorkingBufferPool, AllocationThreshold: 3)
        
        var PixelBuffer: CVPixelBuffer?
        let AuxAttrs = [kCVPixelBufferPoolAllocationThresholdKey as String: 3] as NSDictionary
        CVPixelBufferPoolCreatePixelBufferWithAuxAttributes(kCFAllocatorDefault, WorkingBufferPool, AuxAttrs, &PixelBuffer)
        if let PixelBuffer = PixelBuffer
        {
            CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: PixelBuffer,
                                                         formatDescriptionOut: &OutFormatDesc)
        }
        PixelBuffer = nil
        BufferPool = WorkingBufferPool
    }
    
    /// Holds the color space.
    private static var ColorSpace: CGColorSpace? = nil
    /// Holds the context.
    public static var Context: CIContext? = nil
    public static var OutFormatDesc: CMFormatDescription?
    
    /// Allocate buffers before use.
    /// - Parameters:
    ///   - Pool: The pool of pixel buffers.
    ///   - AllocationThreshold: Threshold value for allocation.
    static func PreAllocateBuffers(Pool: CVPixelBufferPool, AllocationThreshold: Int)
    {
        var PixelBuffers = [CVPixelBuffer]()
        var Error: CVReturn = kCVReturnSuccess
        let AuxAttributes = [kCVPixelBufferPoolAllocationThresholdKey as String: AllocationThreshold] as NSDictionary
        var PixelBuffer: CVPixelBuffer?
        while Error == kCVReturnSuccess
        {
            Error = CVPixelBufferPoolCreatePixelBufferWithAuxAttributes(kCFAllocatorDefault, Pool,
                                                                        AuxAttributes, &PixelBuffer)
            if let PixelBuffer = PixelBuffer
            {
                PixelBuffers.append(PixelBuffer)
            }
            PixelBuffer = nil
        }
        PixelBuffers.removeAll()
    }
    
    static var BufferPool: CVPixelBufferPool? = nil
    
    /// Returns a dictionary of options for the passed filter.
    /// - Note: Values in the `Settings` system are used to populate the returned dictionary. If a given
    ///          filter does not have any options, an empty dictionary is returned.
    /// - Parameter For: The filter whose option dictionary is populated with `Settings` values.
    /// - Returns: Dictionary of options for the passed filter. May be empty if a given filter does not have
    ///            any options.
    public static func GetOptions(For Filter: BuiltInFilters) -> [FilterOptions: Any]
    {
        var Options = [FilterOptions: Any]()
        switch Filter
        {
            case .ImageDelta:
                Options[.IntCommand] = Settings.GetInt(.ImageDeltaCommand)
                Options[.Threshold] = Settings.GetDouble(.ImageDeltaThreshold,
                                                         Settings.SettingDefaults[.ImageDeltaThreshold] as! Double)
                Options[.UseEffective] = Settings.GetBool(.ImageDeltaUseEffectiveColor)
                Options[.EffectiveColor] = Settings.GetColor(.ImageDeltaEffectiveColor,
                                                             Settings.SettingDefaults[.ImageDeltaEffectiveColor] as! UIColor)
                Options[.BGColor] = Settings.GetColor(.ImageDeltaBackground,
                                                      Settings.SettingDefaults[.ImageDeltaBackground] as! UIColor)
            
            case .MultiFrameCombiner:
                Options[.IntCommand] = Settings.GetInt(.MultiFrameCombinerCommand)
                Options[.Invert] = Settings.GetBool(.MultiFrameCombinerInvertCommand)
            
            case .CircularWrap:
                Options[.Angle] = Settings.GetDouble(.CircularWrapAngle,
                                                     Settings.SettingDefaults[.CircularWrapAngle] as! Double)
                Options[.Radius] = Settings.GetDouble(.CircularWrapRadius,
                                                     Settings.SettingDefaults[.CircularWrapRadius] as! Double)
            
            case .SmoothLinearGradient:
                Options[.GradientColor0] = Settings.GetColor(.SmoothLinearColor0,
                                                             Settings.SettingDefaults[.SmoothLinearColor0] as! UIColor).ciColor
                Options[.GradientColor1] = Settings.GetColor(.SmoothLinearColor1,
                                                             Settings.SettingDefaults[.SmoothLinearColor1] as! UIColor).ciColor
            
            case .LineScreen:
                Options[.Angle] = Settings.GetDouble(.LineScreenAngle,
                                                     Settings.SettingDefaults[.LineScreenAngle] as! Double)
            
            case .TwirlBump:
                Options[.TwirlRadius] = Settings.GetDouble(.TwirlBumpTwirlRadius,
                                                           Settings.SettingDefaults[.TwirlBumpTwirlRadius] as! Double)
                Options[.BumpRadius] = Settings.GetDouble(.TwirlBumpBumpRadius,
                                                           Settings.SettingDefaults[.TwirlBumpBumpRadius] as! Double)
                Options[.Angle] = Settings.GetDouble(.TwirlBumpAngle,
                                                     Settings.SettingDefaults[.TwirlBumpAngle] as! Double)
            
            case .MetalPixellate:
                Options[.Width] = Settings.GetInt(.MetalPixWidth, IfZero: 24)
                Options[.Height] = Settings.GetInt(.MetalPixHeight, IfZero: 24)
                Options[.ColorDetermination] = Settings.GetInt(.MetalPixColorDetermination)
                Options[.Highlight] = Settings.GetInt(.MetalPixHighlightPixel)
                Options[.Merge] = Settings.GetBool(.MetalPixMergeImage)
                Options[.By] = Settings.GetInt(.MetalPixHighlightPixel)
                Options[.IsGreater] = Settings.GetBool(.MetalPixInvertThreshold)
                Options[.HAction] = 0
                Options[.IntCommand] = 0
                Options[.Threshold] = Settings.GetDouble(.MetalPixThreshold, 0.5)
                Options[.ShowBorder] = Settings.GetBool(.MetalPixShowBorder)
                Options[.BorderColor] = Settings.GetColor(.MetalPixBorderColor,
                                                          Settings.SettingDefaults[.MetalPixBorderColor] as! UIColor)
            
            case .Kuwahara:
                Options[.Radius] = Settings.GetDouble(.KuwaharaRadius,
                                                      Settings.SettingDefaults[.KuwaharaRadius] as! Double)
            
            case .SolarizeRGB:
                Options[.IntCommand] = Settings.GetInt(.SolarizeHow)
                Options[.IsGreater] = Settings.GetBool(.SolarizeIfGreater)
                Options[.OnlyChannel] = Settings.GetBool(.SolarizeOnlyChannel)
                switch Settings.GetInt(.SolarizeHow)
                {
                    case 0:
                        Options[.Threshold] = Settings.GetDouble(.SolarizeThresholdHigh)
                        
                    case 1:
                        Options[.Threshold] = Settings.GetDouble(.SolarizeRedThreshold)
                        
                    case 2:
                        Options[.Threshold] = Settings.GetDouble(.SolarizeGreenThreshold)
                        
                    case 3:
                        Options[.Threshold] = Settings.GetDouble(.SolarizeBlueThreshold)
                        
                    default:
                        break
                }
            
            case .SolarizeHSB:
                Options[.IntCommand] = Settings.GetInt(.SolarizeHow)
                Options[.IsGreater] = Settings.GetBool(.SolarizeIfGreater)
                switch Settings.GetInt(.SolarizeHow)
                {
                    case 0:
                        Options[.Threshold] = Settings.GetDouble(.SolarizeThresholdHigh)
                        
                    case 1:
                        Options[.Threshold] = Settings.GetDouble(.SolarizeHighHue)
                        
                    case 2:
                        Options[.Threshold] = Settings.GetDouble(.SolarizeSaturationThresholdHigh)
                        
                    case 3:
                        Options[.Threshold] = Settings.GetDouble(.SolarizeBrightnessThresholdHigh)
                        
                    default:
                        break
                }
            
            case .Solarize:
                Options[.IntCommand] = Settings.GetInt(.SolarizeHow)
                Options[.ThresholdAllLow] = Settings.GetDouble(.SolarizeThresholdLow,
                                                               Settings.SettingDefaults[.SolarizeThresholdLow] as! Double)
                Options[.ThresholdAllHigh] = Settings.GetDouble(.SolarizeThresholdHigh,
                                                               Settings.SettingDefaults[.SolarizeThresholdHigh] as! Double)
                Options[.LowHue] = Settings.GetDouble(.SolarizeLowHue,
                                                               Settings.SettingDefaults[.SolarizeLowHue] as! Double)
                Options[.HighHue] = Settings.GetDouble(.SolarizeHighHue,
                                                                Settings.SettingDefaults[.SolarizeHighHue] as! Double)
                Options[.BrightnessThresholdLow] = Settings.GetDouble(.SolarizeBrightnessThresholdLow,
                                                      Settings.SettingDefaults[.SolarizeBrightnessThresholdLow] as! Double)
                Options[.BrightnessThresholdHigh] = Settings.GetDouble(.SolarizeBrightnessThresholdHigh,
                                                       Settings.SettingDefaults[.SolarizeBrightnessThresholdHigh] as! Double)
                Options[.SaturationThresholdLow] = Settings.GetDouble(.SolarizeSaturationThresholdLow,
                                                                      Settings.SettingDefaults[.SolarizeSaturationThresholdLow] as! Double)
                Options[.SaturationThresholdHigh] = Settings.GetDouble(.SolarizeSaturationThresholdHigh,
                                                                       Settings.SettingDefaults[.SolarizeSaturationThresholdHigh] as! Double)
                Options[.IsGreater] = Settings.GetBool(.SolarizeIfGreater)
            
            case .BayerDecode:
                Options[.Order] = Settings.GetInt(.BayerDecodeOrder)
                Options[.Method] = Settings.GetInt(.BayerDecodeMethod)
            
            case .ConditionalSilhouette:
                Options[.CSTrigger] = Settings.GetInt(.ConditionalSilhouetteTrigger)
                Options[.CSColor] = Settings.GetColor(.ConditionalSilhouetteColor, UIColor.black)
                Options[.CSHueThreshold] = Settings.GetDouble(.ConditionalSilhouetteHueThreshold,
                                                              Settings.SettingDefaults[.ConditionalSilhouetteHueThreshold] as! Double)
                Options[.CSHueRange] = Settings.GetDouble(.ConditionalSilhouetteHueRange,
                                                              Settings.SettingDefaults[.ConditionalSilhouetteHueRange] as! Double)
                Options[.CSSatThreshold] = Settings.GetDouble(.ConditionalSilhouetteSatThreshold,
                                                              Settings.SettingDefaults[.ConditionalSilhouetteSatThreshold] as! Double)
                Options[.CSSatRange] = Settings.GetDouble(.ConditionalSilhouetteSatRange,
                                                          Settings.SettingDefaults[.ConditionalSilhouetteSatRange] as! Double)
                Options[.CSBriThreshold] = Settings.GetDouble(.ConditionalSilhouetteBriThreshold,
                                                              Settings.SettingDefaults[.ConditionalSilhouetteBriThreshold] as! Double)
                Options[.CSBriRange] = Settings.GetDouble(.ConditionalSilhouetteBriRange,
                                                          Settings.SettingDefaults[.ConditionalSilhouetteBriRange] as! Double)
            
            case .ChannelMixer:
                Options[.Channel1] = Settings.GetInt(.ChannelMixerChannel1)
                Options[.Channel2] = Settings.GetInt(.ChannelMixerChannel2)
                Options[.Channel3] = Settings.GetInt(.ChannelMixerChannel3)
                Options[.InvertChannel1] = Settings.GetBool(.ChannelMixerInvertChannel1)
                Options[.InvertChannel2] = Settings.GetBool(.ChannelMixerInvertChannel2)
                Options[.InvertChannel3] = Settings.GetBool(.ChannelMixerInvertChannel3)
            
            case .ChannelMangler:
                Options[.IntCommand] = Settings.GetInt(.ChannelManglerOperation)
            
            case .MetalGrayscale:
                Options[.IntCommand] = Settings.GetInt(.GrayscaleMetalCommand)
                Options[.RedMultiplier] = Settings.GetDouble(.GrayscaleRedMultiplier,
                                                             Settings.SettingDefaults[.GrayscaleRedMultiplier] as! Double)
                Options[.GreenMultiplier] = Settings.GetDouble(.GrayscaleGreenMultiplier,
                                                             Settings.SettingDefaults[.GrayscaleGreenMultiplier] as! Double)
                Options[.BlueMultiplier] = Settings.GetDouble(.GrayscaleBlueMultiplier,
                                                             Settings.SettingDefaults[.GrayscaleBlueMultiplier] as! Double)
            
            case .Convolution:
                Options[.Bias] = Settings.GetDouble(.ConvolutionBias,
                                                    Settings.SettingDefaults[.ConvolutionBias] as! Double)
                Options[.Width] = Settings.GetInt(.ConvolutionWidth,
                                                  IfZero: Settings.SettingDefaults[.ConvolutionWidth] as! Int)
                Options[.Height] = Settings.GetInt(.ConvolutionHeight,
                                                   IfZero: Settings.SettingDefaults[.ConvolutionHeight] as! Int)
                Options[.Matrix] = Settings.GetMatrix(.ConvolutionKernel,
                                                      CreateIfEmpty: true) ??
                    Settings.SettingDefaults[.ConvolutionKernel] as! [[Double]]
            
            case .Threshold:
                Options[.LowColor] = Settings.GetColor(.ThresholdLowColor,
                                             Settings.SettingDefaults[.ThresholdLowColor] as! UIColor)
                Options[.HighColor] = Settings.GetColor(.ThresholdHighColor,
                                                        Settings.SettingDefaults[.ThresholdHighColor] as! UIColor)
                Options[.ThresholdInput] = Settings.GetInt(.ThresholdInputChannel)
                Options[.ApplyIfHigher] = Settings.GetBool(.ThresholdApplyIfGreater)
                Options[.Threshold] = Settings.GetDouble(.ThresholdValue,
                                                         Settings.SettingDefaults[.ThresholdValue] as! Double)
            
            case .EdgeWork:
                Options[.Intensity] = Settings.GetDouble(.EdgeWorkThickness,
                                                         Settings.SettingDefaults[.EdgeWorkThickness] as! Double)
            
            case .Sepia:
                Options[.Intensity] = Settings.GetDouble(.SepiaIntensity,
                                                         Settings.SettingDefaults[.SepiaIntensity] as! Double)
            
            case .TwirlDistortion:
                Options[.Radius] = Settings.GetDouble(.TwirlRadius,
                                                      Settings.SettingDefaults[.TwirlRadius] as! Double)
                Options[.Angle] = Settings.GetDouble(.TwirlAngle,
                                                      Settings.SettingDefaults[.TwirlAngle] as! Double)
            
            case .ExposureAdjust:
                Options[.ExposureValue] = Settings.GetDouble(.ExposureValue,
                                                             Settings.SettingDefaults[.ExposureValue] as! Double)
            
            case .Edges:
                Options[.Intensity] = Settings.GetDouble(.EdgesIntensity,
                                                         Settings.SettingDefaults[.EdgesIntensity] as! Double)
            
            case .Droste:
                Options[.Strands] = Settings.GetDouble(.DrosteStrands,
                                                       Settings.SettingDefaults[.DrosteStrands] as! Double)
                Options[.Periodicity] = Settings.GetDouble(.DrostePeriodicity,
                                                           Settings.SettingDefaults[.DrostePeriodicity] as! Double)
                Options[.Rotation] = Settings.GetDouble(.DrosteRotation,
                                                        Settings.SettingDefaults[.DrosteRotation] as! Double)
                Options[.Zoom] = Settings.GetDouble(.DrosteZoom,
                                                    Settings.SettingDefaults[.DrosteZoom] as! Double)
            
            case .Dither:
                Options[.DitherIntensity] = Settings.GetDouble(.DitherIntensity,
                                                         Settings.SettingDefaults[.DitherIntensity] as! Double)
            
            case .DotScreen:
                Options[.Sharpness] = Settings.GetDouble(.DotScreenSharpness,
                                                         Settings.SettingDefaults[.DotScreenSharpness] as! Double)
                Options[.Width] = Settings.GetDouble(.DotScreenWidth,
                                                     Settings.SettingDefaults[.DotScreenWidth] as! Double)
                Options[.Angle] = Settings.GetDouble(.DotScreenAngle,
                                                     Settings.SettingDefaults[.DotScreenAngle] as! Double)
                
            case .CMYKHalftone:
                Options[.Sharpness] = Settings.GetDouble(.CMYKHalftoneSharpness,
                                                     Settings.SettingDefaults[.CMYKHalftoneSharpness] as! Double)
                Options[.Width] = Settings.GetDouble(.CMYKHalftoneWidth,
                                                    Settings.SettingDefaults[.CMYKHalftoneWidth] as! Double)
                Options[.Angle] = Settings.GetDouble(.CMYKHalftoneAngle,
                                                     Settings.SettingDefaults[.CMYKHalftoneAngle] as! Double)
            
            case .CircleSplashDistortion:
                Options[.Radius] = Settings.GetDouble(.CircleSplashDistortionRadius,
                                                      Settings.SettingDefaults[.CircleSplashDistortionRadius] as! Double)
            
            case .ColorMonochrome:
                Options[.Color] = Settings.GetColor(.ColorMonochromeColor)
                
            case .ColorMap:
                Options[.Color0] = Settings.GetColor(.ColorMapColor1)
                Options[.Color1] = Settings.GetColor(.ColorMapColor2)

            case .HueAdjust:
                Options[.Angle] = Settings.GetDouble(.HueAngle, 0.0)
                
            case .Kaleidoscope:
                Options[.Count] = Settings.GetInt(.KaleidoscopeSegmentCount)
                Options[.Angle] = Settings.GetInt(.KaleidoscopeAngleOfReflection)
                Options[.BackgroundFill] = Settings.GetBool(.KaleidoscopeFillBackground) 

            case .TriangleKaleidoscope:
                Options[.Size] = Settings.GetDouble(.Kaleidoscope3Size,
                                                    Settings.SettingDefaults[.Kaleidoscope3Size] as! Double)
                Options[.Angle] = Settings.GetDouble(.Kaleidoscope3Rotation,
                                                     Settings.SettingDefaults[.Kaleidoscope3Rotation] as! Double)
                Options[.Decay] = Settings.GetDouble(.Kaleidoscope3Decay,
                                                     Settings.SettingDefaults[.Kaleidoscope3Decay] as! Double)
                
            case .BumpDistortion:
                Options[.Radius] = Settings.GetDouble(.BumpDistortionRadius,
                                                      Settings.SettingDefaults[.BumpDistortionRadius] as! Double)
                Options[.Scale] = Settings.GetDouble(.BumpDistortionScale,
                                                      Settings.SettingDefaults[.BumpDistortionScale] as! Double)
                
            case .Vibrance:
                Options[.Amount] = Settings.GetDouble(.VibranceAmount,
                                                      Settings.SettingDefaults[.VibranceAmount] as! Double)
                
            case .ColorControls:
                Options[.Brightness] = Settings.GetDouble(.ColorControlsBrightness,
                                                          Settings.SettingDefaults[.ColorControlsBrightness] as! Double)
                Options[.Contrast] = Settings.GetDouble(.ColorControlsBrightness,
                                                          Settings.SettingDefaults[.ColorControlsContrast] as! Double)
                Options[.Saturation] = Settings.GetDouble(.ColorControlsBrightness,
                                                          Settings.SettingDefaults[.ColorControlsSaturation] as! Double)
                
            case .UnsharpMask:
                Options[.Intensity] = Settings.GetDouble(.UnsharpIntensity,
                                                         Settings.SettingDefaults[.UnsharpIntensity] as! Double)
                Options[.Radius] = Settings.GetDouble(.UnsharpRadius,
                                                         Settings.SettingDefaults[.UnsharpRadius] as! Double)
                
            default:
                break
        }
        return Options
    }
    
    /// List of filters that are intended for use only on videos.
    public static let VideoOnlyFilters = [BuiltInFilters.TrailingFrames]
    
    /// List of filter names that are intended only for videos.
    public static let VideoOnlyFilterNames = [BuiltInFilters.TrailingFrames.rawValue]
    
    /// List of filters that are too slow to run in real-time and so are not available in live view.
    public static let NonRealTimeFilters = [BuiltInFilters.Kuwahara]
    
    /// List of filter names that are too slow to run in real-time.
    public static let NonRealTimeFilterNames = [BuiltInFilters.Kuwahara.rawValue]
    
    public static func HasSpecialSymbol(_ FilterName: String) -> Bool
    {
        if VideoOnlyFilterNames.contains(FilterName)
        {
            return true
        }
        if NonRealTimeFilterNames.contains(FilterName)
        {
            return true
        }
        return false
    }
    
    public static func GetTitleSymbol(For Title: String) -> String
    {
        if VideoOnlyFilterNames.contains(Title)
        {
            return "rectangle.stack"
        }
        if NonRealTimeFilterNames.contains(Title)
        {
            return "tortoise"
        }
        return ""
    }
    
    public static func TitleHasSymbol(_ Title: String) -> Bool
    {
        return !GetTitleSymbol(For: Title).isEmpty
    }
    
    /// Determines if the passed filter is real-time or not.
    /// - Note: Real-time filters are sufficiently performant that they can be used in live views.
    /// - Parameter Filter: The filter to determine fitness for live view.
    /// - Returns: True if the filter can be used for live views, false if not.
    public static func IsRealTime(_ Filter: BuiltInFilters) -> Bool
    {
        return !NonRealTimeFilters.contains(Filter)
    }
    
    /// Sets the default filter.
    /// - Parameter NewFilter: Filter to use as the default filter.
    public static func SetFilter(_ NewFilter: BuiltInFilters)
    {
        LastBuiltInFilterUsed = NewFilter
    }
    
    /// Holds the last filter used.
    static var LastBuiltInFilterUsed: BuiltInFilters? = nil
    
    /// Group color data.
    static var GroupData: [FilterGroups: Int] =
        [
            .Adjust: 0x98fb98,
            .Blur: 0x89cff0,
            .Color: 0xffef00,
            .Combined: 0xff9966,
            .Distortion: 0xf88379,
            .Halftone: 0xbc8f8f,
            .Sharpen: 0xddd06a,
            .ThreeD: 0xccccff,
            .Information: 0xfe4eda,
            .Effect: 0xbfff00,
            .Grayscale: 0xbcbcbc,
            .Reset: 0xffffff,
            .Edges: 0xfae6fa,
            .MultiFrame: 0xea71c6,
            .Test: 0xffe0d0,
            .NonLiveView: 0xa070d0
        ]
    
    /// Returns the current filter (stored in user settings at `.CurrentFilter`) to the caller.
    /// - Parameter Default: Filter name (see `BuiltInFilters`) to use if there is no value in
    ///                      `.CurrentFilter` or the valid is invalid. Defaults to the name for
    ///                      `.Passthrough`.
    /// - Returns: The `BuiltInFilters` enum equivalent for the current filter on success. If the stored
    ///            filter name is invalid, the `BuiltInFilters` equivalent for `Default` is returned. If that
    ///            is invalid, `.Passthrough` is returned.
    static func GetFilter(_ Default: String = BuiltInFilters.Passthrough.rawValue) -> BuiltInFilters
    {
        if let Stored = Settings.GetString(.CurrentFilter)
        {
            if let SomeFilter = BuiltInFilters(rawValue: Stored)
            {
                return SomeFilter
            }
        }
        if let IsValid = BuiltInFilters(rawValue: Default)
        {
            return IsValid
        }
        return .Passthrough
    }
    
    /// Returns a list of all filters, sorted as per the parameter.
    /// - Parameter SortAscending: If true, data returned in ascending order (sorted on first tuple element).
    ///                            If false, data returned in descending order. Defaults to `true`.
    /// - Returns: Array of sorted filter data in an array of tuples. Tuple structure is (Filter Name, Filter
    ///            Description, Filter enum).
    static func AllFilters(SortAscending: Bool = true) -> [(String, String, BuiltInFilters)]
    {
        var Final = [(String, String, BuiltInFilters)]()
        Final = BuiltInFilters.allCases.map({($0.rawValue,
                                              GetFilterDescription(For: $0),
                                              $0)})
        if SortAscending
        {
            Final.sort(by: {$0.0 < $1.0})
        }
        else
        {
            Final.sort(by: {$0.0 > $1.0})
        }
        return Final
    }
    
    /// Returns an array of grouped filters.
    /// - Returns: Array of a tuple of the format (Group Name, Filter Name, Filter enum).
    static func GroupedFilters() -> [(String, String, BuiltInFilters)]
    {
        var Grouped = [(String, String, BuiltInFilters)]()
        for (Group, FiltersInGroup) in FilterTree
        {
            var IFilterList = [(String, BuiltInFilters)]()
            for SomeFilter in FiltersInGroup
            {
                IFilterList.append((SomeFilter.key.rawValue, SomeFilter.key))
            }
            IFilterList.sort(by: {$0.0 < $1.0})
            for SomeFilter in IFilterList
            {
                Grouped.append((Group.rawValue, SomeFilter.0, SomeFilter.1))
            }
        }
        Grouped.sort(by: {$0.0 < $1.0})
        return Grouped
    }
    
    /// Returns a short description for the passed filter. If the filter is not recognized, a generic
    /// error message is returned.
    /// - Parameter For: The filter whose description will be returned.
    /// - Returns: Short description of the passed filter. If not found, a generic error message is returned.
    public static func GetFilterDescription(For Filter: BuiltInFilters) -> String
    {
        if let Description = Descriptions[Filter]
        {
            return Description
        }
        return "No description found for \"\(Filter.rawValue)\"."
    }
    
    /// Returns the group a given filter belongs to.
    /// - Parameter Filter: The filter whose group will be returned.
    /// - Returns: The filter group for the passed `Filter` on success. If not found, `.Reset` is returned.
    public static func GroupFor(Filter: BuiltInFilters) -> FilterGroups
    {
        for (Group, FiltersInGroup) in FilterTree
        {
            if FiltersInGroup.keys.contains(Filter)
            {
                return Group
            }
        }
        return .Reset
    }
    
    /// Given a group name, return a description of the group.
    /// - Parameter For: The name of the group.
    /// - Returns: Short description of the group on success. If not found, the description for
    ///            the `.Reset` group is returned.
    public static func GroupDescription(For Name: String) -> String
    {
        if let SearchGroup = FilterGroups(rawValue: Name)
        {
            if let Description = GroupDescriptions[SearchGroup]
            {
                return Description
            }
        }
        return GroupDescriptions[.Reset]!
    }
    
    public static let GroupDescriptions: [FilterGroups: String] =
        [
            .Adjust: "Whole image adjustment",
            .Blur: "Image blurring",
            .Color: "Whole image color adjustments",
            .Combined: "Combined filters",
            .Distortion: "Image distortion",
            .Edges: "Edge detection and display",
            .Effect: "Image effects",
            .Grayscale: "Black and white filters",
            .Halftone: "Halftone filters",
            .Information: "Informational filters",
            .MultiFrame: "Filters for multiple images",
            .NonLiveView: "Filters that are very slow",
            .Reset: "Passthrough filters",
            .Sharpen: "Image sharpening",
            .Test: "Test filters",
            .ThreeD: "Filters that use 3D processing"
        ]
    
    /// Short descriptions for each filter.
    public static let Descriptions: [BuiltInFilters: String] =
        [
            .Passthrough: "Passthrough - no filtering done.",
            .LineOverlay: "Halftone line screen overlayed original image.",
            .Pixellate: "Image pixellation.",
            .FalseColor: "Built-in false color filter.",
            .HueAdjust: "Image hue adjustment.",
            .ExposureAdjust: "Image exposure adjustment.",
            .Posterize: "Level posterization filter.",
            .Noir: "Black and white noir filter.",
            .LinearTosRGB: "Linear RGB to sRGB colorspace conversion.",
            .Chrome: "Built-in vibrance and color lightening filter.",
            .Sepia: "Built-in sepia tone filter.",
            .DotScreen: "Halftone dot-screen filter.",
            .LineScreen: "Halftone line screen filter.",
            .CircularScreen: "Halftone circular screen filter.",
            .HatchedScreen: "Halftone hatched screen filter.",
            .CMYKHalftone: "Halftone CMYK screen filter.",
            .Instant: "Built-in instant image effect.",
            .Fade: "Built-in faded image effect.",
            .Mono: "Built-in black and white image effect.",
            .Process: "Built-in process image effect.",
            .Tonal: "Built-in tonal image effect.",
            .Transfer: "Built-in transfer image effect.",
            .Vibrance: "Built-in vibrance increase effect.",
            .XRay: "Built-in X-Ray-like effect.",
            .Comic: "Built-in comic style effect.",
            .TriangleKaleidoscope: "Built-in triangular kaleidoscope distortion.",
            .Kaleidoscope: "Built-in kaleidoscope distortion.",
            .ColorMonochrome: "Built-in monochromatic color effect.",
            .MaximumComponent: "Built-in maximum grayscale channel effect.",
            .MinimumComponent: "Built-in minimum grayscale channel effect.",
            .HistogramDisplay: "Display a histogram of the view.",
            .SharpenLuminance: "Luminance image sharpening.",
            .UnsharpMask: "Image sharpening.",
            .Bloom: "Built-in color bloom filter effect.",
            .HexagonalPixellate: "Image pixellation with hexagonal pixels.",
            .Crystallize: "Built-in \"crystallization\" effect.",
            .Edges: "Built-in edge detection effect.",
            .EdgeWork: "Black and white edge detection effect.",
            .Gloom: "Built-in color darkening effect.",
            .Pointillize: "Pointillization image effect.",
            .LinearGradient: "Image mapped to linear color gradient.",
            .SmoothLinearGradient: "Image mapped to linear color gradiant.",
            .ColorMap: "Image mapped to color gradient.",
            .MaskToAlpha: "Internal: Masking image to alpha channel.",
            .SourceATop: "Internal: Merge images.",
            .CircleAndLines: "Halftone combination of circular and line screen filters.",
            .LineScreenBlend: "Halftone line screen overlayed original image.",
            .CircleScreenBlend: "Halftone circle screen overlayed with original image.",
            .ThermalEffect: "Built-in thermal color mapping effect.",
            .TwirlDistortion: "Built-in twirl distortion.",
            .LightTunnel: "Built-in light tunnel distortion.",
            .HoleDistortion: "Built-in hole in the middle distortion.",
            .Droste: "Built-in droste (repeating pattern) distortion.",
            .CircleSplashDistortion: "Built-in circle-splash distortion.",
            .BumpDistortion: "Built-in bump distortion.",
            .AreaHistogram: "Internal: Histogram function.",
            .ColorInvert: "Color inversion effect.",
            .ColorInvert2: "Conditional color inversion effect.",
            .GrayscaleInvert: "Inverted grayscale effect.",
            .GaussianBlur: "Built-in Gaussian blur effect.",
            .MedianFilter: "Built-in median blur effect.",
            .MotionBlur: "Built-in motion blur effect.",
            .ZoomBlur: "Built-in zoom blur effect.",
            .Masking1: "Internal: Masking filter.",
            .GradientToAlpha: "Internal: Gradient colors to alpha channel.",
            .AlphaBlend: "Internal: Blend two alpha-enabled images together.",
            .Mirroring2: "Image mirroring.",
            .Threshold: "Conditional threshold filter.",
            .Laplacian: "Laplacian kernel edge processing.",
            .Dilate: "Dilation kernel edge processing.",
            .Emboss: "Emboss kernel edge processing.",
            .Erode: "Erode kernel edge processing.",
            .Sobel: "Sobel kernel edge processing.",
            .SobelBlend: "Sobel kernel edge processing with original image.",
            .Median: "Built-in median image processing.",
            .GaborGradients: "Built-in Gabor gradient edge processing.",
            .GammaAdjust: "Image gamma level adjustment.",
            .HeightField: "Built-in height field processing.",
            .SaliencyMap: "Does not work - very very bad.",
            .MorphologyGradient: "Color image edge processing.",
            .ColorControls: "Color adjustments.",
            .ConditionalTransparency: "Conditional transparency filter.",
            .ImageDelta: "Delta of two images filter.",
            .AreaMax: "Maximum color in image region filter.",
            .Convolution: "Kernel convolution filter.",
            .MetalGrayscale: "Grayscale image processing.",
            .ChannelMangler: "Color channel mangling for surreal results.",
            .ConditionalSilhouette: "Conditional silhouette filter.",
            .ChannelMixer: "Color channel mixer.",
            .BayerDecode: "Bayer-encoded image decoder.",
            .Solarize: "Image solarization.",
            .SolarizeHSB: "Solarize image with HSB channels.",
            .SolarizeRGB: "Solarize image with RGB channels.",
            .Kuwahara: "Kuwahara smoothing. Very slow.",
            .MetalPixellate: "Pixellation with various parameters and borders.",
            .TwirlBump: "Combination of Bump and Twirl filters.",
            .Crop: "Internal: Crop an image.",
            .Crop2: "Internal: Crop an image.",
            .Reflect: "Reflection test.",
            .QuadrantTest: "Quadrant reflection test.",
            .MatrixTest: "Matrix test.",
            .Blocks: "3D block image.",
            .Spheres: "3D sphere image.",
            .HSB: "Color adjustment with hue, saturation, and brightness settings.",
            .Dither: "Built-in color dithering.",
            .CircularWrap: "Circular wrapping of the image.",
            .BrightnessMask: "Mask to alpha depending on brightness of pixel.",
            .MultiFrameCombiner: "Combine frames together",
            .TrailingFrames: "Video-only time-based frame combining.",
        ]
}

/// High-level filter groups.
enum FilterGroups: String, CaseIterable
{
    case Adjust = "Adjust"
    case Blur = "Blur"
    case Color = "Color"
    case Combined = "Combined"
    case Distortion = "Distortion"
    case Halftone = "Halftone"
    case Effect = "Effect"
    case Sharpen = "Sharpen"
    case ThreeD = "3D"
    case Grayscale = "Grayscale"
    case Information = "Information"
    case Reset = " Reset "
    case Edges = "Edges"
    case MultiFrame = "Frames"
    case Test = "Test/Debug"
    case NonLiveView = "Non-Live View"
}

/// Individual filters.
enum BuiltInFilters: String, CaseIterable
{
    case Passthrough = "No Filter"
    case LineOverlay = "Line Overlay" 
    case Pixellate = "Pixellate"
    case FalseColor = "False Color"
    case HueAdjust = "Hue"
    case ExposureAdjust = "Exposure"
    case Posterize = "Posterize"
    case Noir = "Noir"
    case LinearTosRGB = "Linear to sRGB"
    case Chrome = "Chrome"
    case Sepia = "Sepia"
    case DotScreen = "Dot Screen"
    case LineScreen = "Line Screen"
    case CircularScreen = "Circular Screen"
    case HatchedScreen = "Hatch Screen"
    case CMYKHalftone = "CMYK Halftone"
    case Instant = "Instant"
    case Fade = "Fade"
    case Mono = "Mono"
    case Process = "Process"
    case Tonal = "Tonal"
    case Transfer = "Transfer"
    case Vibrance = "Vibrance "
    case XRay = "X-Ray"
    case Comic = "Comic"
    case TriangleKaleidoscope = "Triangle Kaleido."
    case Kaleidoscope = "Kaleidoscope"
    case ColorMonochrome = "Color Mono"
    case MaximumComponent = "Maximum"
    case MinimumComponent = "Minimum"
    case HistogramDisplay = "Histogram"
    case SharpenLuminance = "Sharpen Luminance"
    case UnsharpMask = "Unsharp Mask"
    case Bloom = "Bloom"
    case Crystallize = "Crystallize"
    case Edges = "Edges"
    case EdgeWork = "Edge Work"
    case Gloom = "Gloom"
    case HexagonalPixellate = "Pixellate Hex"
    case Pointillize = "Pointillize"
    case LinearGradient = "Linear Gradient"
    case SmoothLinearGradient = "Smooth Linear Gradient"
    case ColorMap = "Color Map"
    case MaskToAlpha = "Mask to Alpha"
    case SourceATop = "Source Atop"
    case CircleAndLines = "Circle+Lines"
    case LineScreenBlend = "Lines+BG"
    case CircleScreenBlend = "Circle+BG"
    case ThermalEffect = "Thermal"
    case TwirlDistortion = "Twirl"
    case LightTunnel = "Spiral"
    case HoleDistortion = "Hole"
    case Droste = "Droste"
    case CircleSplashDistortion = "Circle Splash"
    case BumpDistortion = "Bump"
    case AreaHistogram = "Area Histogram"
    case ColorInvert = "Invert"
    case ColorInvert2 = "Invert 2"
    case GrayscaleInvert = "B/W Invert"
    case GaussianBlur = "Gaussian"
    case MedianFilter = "Median Old"
    case MotionBlur = "Motion"
    case ZoomBlur = "Zoom"
    case Masking1 = "Masking1"
    case GradientToAlpha = "Gradient->Alpha"
    case AlphaBlend = "AlphaBlend"
//    case Mirroring = "Mirroring"
    case Mirroring2 = "Mirroring 2"
    case Threshold = "Threshold"
    case Laplacian = "Laplacian"
    case Dilate = "Dilate"
    case Emboss = "Emboss"
    case Erode = "Erode"
    case Sobel = "Sobel"
    case SobelBlend = "Sobel+BG"
    case Median = "Median"
    case Otsu = "Otsu"
    case Dither = "Dither"
    case GaborGradients = "Gabor"
    case GammaAdjust = "Gamma"
    case HeightField = "Height Field"
    case SaliencyMap = "Saliency Map"
    case MorphologyGradient = "Morphology"
    case ColorControls = "Control"
    case ConditionalTransparency = "Conditional Transparency"
    case ImageDelta = "Image Delta"
    case HSB = "HSB"
    case ThresholdInput = "Threshold Input"
    case ApplyIfGreater = "Apply If Greater"
    case LowColor = "Low Color"
    case HighColor = "High Color"
    case AreaMax = "Area Max"
    case Convolution = "Convolution"
    case MetalGrayscale = "Grayscale 2"
    case ChannelMangler = "Channels"
    case ConditionalSilhouette = "Conditional Silhouette"
    case ChannelMixer = "Channel Mixer"
    case BayerDecode = "Bayer Decode"
    case Solarize = "Solarize"
    case SolarizeHSB = "Solarize HSB"
    case SolarizeRGB = "Solarize RGB"
    case Kuwahara = "Kuwahara"
    case MetalPixellate = "Metal Pixellate"
    case TwirlBump = "Twirl Bump"
    case CircularWrap = "Circular Wrap"
    case MultiFrameCombiner = "Frame Combiner"
    case TrailingFrames = "Trailing Frames"
    
    //Internal filters
    case Crop = "Crop"
    case Crop2 = "Crop2"
    case Reflect = "Reflect"
    case QuadrantTest = "Quadrant Test"
    case MatrixTest = "Matrix Test"
    case BrightnessMask = "Brightness Mask"
    
    //3D Filters
    case Blocks = "Blocks"
    case Spheres = "Spheres"
}
