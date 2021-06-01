//
//  FilterOptiosn.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/31/21.
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

extension Filters
{
    // MARK: - Filter-option-related functions.
    
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
            case .SimpleInversion:
                Options[.Invert] = Settings.GetInt(.SimpleInversionChannel)
            
            case .MetalCheckerboard:
                Options[.Size] = Settings.GetInt(.MCheckerCheckSize)
                Options[.Width] = Settings.GetInt(.MCheckerWidth)
                Options[.Height] = Settings.GetInt(.MCheckerHeight)
                Options[.Color0] = Settings.GetColor(.MCheckerColor0,
                                                     Settings.SettingDefaults[.MCheckerColor0] as! UIColor)
                Options[.Color1] = Settings.GetColor(.MCheckerColor1,
                                                     Settings.SettingDefaults[.MCheckerColor1] as! UIColor)
                Options[.Color2] = Settings.GetColor(.MCheckerColor2,
                                                     Settings.SettingDefaults[.MCheckerColor2] as! UIColor)
                Options[.Color3] = Settings.GetColor(.MCheckerColor3,
                                                     Settings.SettingDefaults[.MCheckerColor3] as! UIColor)
                
            case .ColorRange:
                Options[.IntCommand] = Settings.GetInt(.ColorRangeOutOfRangeAction)
                Options[.StartRange] = Settings.GetDouble(.ColorRangeStart,
                                                          Settings.SettingDefaults[.ColorRangeStart] as! Double)
                Options[.EndRange] = Settings.GetDouble(.ColorRangeEnd,
                                                        Settings.SettingDefaults[.ColorRangeEnd] as! Double)
                Options[.Invert] = Settings.GetBool(.ColorRangeInvertRange)
                Options[.NonRangeColor] = Settings.GetColor(.ColorRangeOutOfRangeColor,
                                                            Settings.SettingDefaults[.ColorRangeOutOfRangeColor] as! UIColor)
                
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
                Options[.BGColor] = Settings.GetColor(.MetalPixBGColor,
                                                      Settings.SettingDefaults[.MetalPixBGColor] as! UIColor)
                Options[.Shape] = Settings.GetInt(.MetalPixShape, IfZero: 0)
                
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
}


/// Used to specify optional values for filters. Interpretation of filter options depends on the individual
/// filter.
enum FilterOptions: String
{
    case Radius = "Radius"
    case Center = "Center"
    case Angle = "Angle"
    case Scale = "Scale"
    case Zoom = "Zoom"
    case Rotation = "Roation"
    case Periodicity = "Periodicity"
    case Sharpness = "Sharpness"
    case Width = "Width"
    case Height = "Height"
    case ExposureValue = "ExposureValue"
    case Color = "Color"
    case Color0 = "Color0"
    case Color1 = "Color1"
    case Color2 = "Color2"
    case Color3 = "Color3"
    case LowColor = "LowColor"
    case HighColor = "HighColor"
    case GrayscaleFilter = "GrayscaleFilter"
    case Count = "Count"
    case Contrast = "Contrast"
    case Threshold = "Threshold"
    case ThresholdInput = "ThresholdInput"
    case ApplyIfHigher = "ApplyIfHigher"
    case EdgeIntensity = "EdgeIntensity"
    case NRNoiseLevel = "NRNoiseLevel"
    case NRSharpness = "NRSharpness"
    case Levels = "Levels"
    case Point = "Point"
    case Amount = "Amount"
    case Point1 = "Point1"
    case Point2 = "Point2"
    case Strands = "Strands"
    case Intensity = "Intensity"
    case Size = "Size"
    case Merge = "Merge"
    case GradientColor0 = "GradientColor0"
    case GradientColor1 = "GradientColor1"
    case GradientPoint0 = "GradientPoint0"
    case GradientPoint1 = "GradientPoint1"
    case GradientDefinition = "GradientDefinition"
    case ChainedFilters = "ChainedFilters"
    case ShaderBias = "ShaderBias"
    case ErodeWidth = "ErodeWidth"
    case ErodeHeight = "ErodeHeight"
    case DilateWidth = "DilateWidth"
    case DilateHeight = "DilateHeight"
    case EmbossType = "EmbossType"
    case MedianDiameter = "MedianDiameter"
    case DitherIntensity = "DitherIntensity"
    case Power = "Power"
    case Brightness = "Brightness"
    case Saturation = "Saturation"
    case HorizontalMirrorSide = "HorizontalMirrorSide"
    case VerticalMirrorSide = "VerticalMirrorSide"
    case MirrorQuadrant = "MirrorQuadrant"
    case SourceIsAV = "SourceIsAV"
    case Invert = "Invert"
    case Decay = "Decay"
    case FilterName = "FilterName"
    case Hue = "Hue"
    case ChangeHue = "ChangeHue"
    case ChangeSaturation = "ChangeSaturation"
    case ChangeBrightness = "ChangeBrightness"
    case BackgroundFill = "BackgroundFill"
    case Matrix = "Matrix"
    case Bias = "Bias"
    case IntCommand = "IntCommand"
    case RedMultiplier = "RedMultiplier"
    case GreenMultiplier = "GreenMultiplier"
    case BlueMultiplier = "BlueMultiplier"
    case CIColorSpace = "CIColorSpace"
    case CIInvert1 = "CIInvert1"
    case CIInvert2 = "CIInvert2"
    case CIInvert3 = "CIInvert3"
    case CIInvert4 = "CIInvert4"
    case CIEnableThreshold1 = "CIEnableThreshold1"
    case CIEnableThreshold2 = "CIEnableThreshold2"
    case CIEnableThreshold3 = "CIEnableThreshold3"
    case CIEnableThreshold4 = "CIEnableThreshold4"
    case CIThreshold1 = "CIThreshold1"
    case CIThreshold2 = "CIThreshold2"
    case CIThreshold3 = "CIThreshold3"
    case CIThreshold4 = "CIThreshold4"
    case CIInvert1IfGreater = "CIInvert1IfGreater"
    case CIInvert2IfGreater = "CIInvert2IfGreater"
    case CIInvert3IfGreater = "CIInvert3IfGreater"
    case CIInvert4IfGreater = "CIInvert4IfGreater"
    case CIInvertAlpha = "CIInvertAlpha"
    case CIInvertAlphaThreshold = "CIInvertAlphaThreshold"
    case CIAlphaThreshold = "CIAlphaThreshold"
    case CIAlphaInvertIfGreater = "CIAlphaInvertIfGreater"
    case CSTrigger = "CSTrigger"
    case CSHueThreshold = "CSHueThreshold"
    case CSHueRange = "CSHueRange"
    case CSSatThreshold = "CSSatThreshold"
    case CSSatRange = "CSSatRange"
    case CSBriThreshold = "CSBriThreshold"
    case CSBriRange = "CSBriRange"
    case CSGreaterThan = "CSGreaterThan"
    case CSColor = "CSColor"
    case Channel1 = "Channel1"
    case Channel2 = "Channel2"
    case Channel3 = "Channel3"
    case InvertChannel1 = "InvertChannel1"
    case InvertChannel2 = "InvertChannel2"
    case InvertChannel3 = "InvertChannel3"
    case Order = "Order"
    case Method = "Method"
    case ThresholdAllLow = "ThresholdAllLow"
    case ThresholdAllHigh = "ThresholdAllHigh"
    case LowHue = "LowHue"
    case HighHue = "HighHue"
    case BrightnessThresholdLow = "BrightnessThresholdLow"
    case BrightnessThresholdHigh = "BrightnessThresholdHigh"
    case SaturationThresholdLow = "SaturationThreshold"
    case SaturationThresholdHigh = "SaturationThresholdHigh"
    case IsGreater = "IsGreater"
    case OnlyChannel = "OnlyChannel"
    case BumpRadius = "BumpRadius"
    case TwirlRadius = "TwirlRadius"
    case UseEffective = "UseEffective"
    case EffectiveColor = "EffectiveColor"
    case BGColor = "BGColor"
    case NonRangeColor = "NonRangeColor"
    case StartRange = "StartRange"
    case EndRange = "EndRange"
    case Shape = "Shape"
    case HAction = "HAction"
    case VAction = "VAction"
    case By = "By"
    case ColorDetermination = "ColorDetermination"
    case Highlight = "Highlight"
    case ShowBorder = "ShowBorder"
    case BorderColor = "BorderColor"
}
