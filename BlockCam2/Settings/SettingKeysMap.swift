//
//  SettingKeysMap.swift
//  BlockCam2
//  Adapted from 8/27/20.
//
//  Created by Stuart Rankin on 4/27/21.
//

import Foundation
import UIKit

extension Settings
{
    /// Map between a setting key and the type of data it stores.
    public static let SettingKeyTypes: [SettingKeys: Any] =
        [
            // MARK: - Infrastructure/initialization-related settings.
            .InitializationFlag: Bool.self,
            .InstanceID: String.self,
            
            // MARK: - Audio settings
            .ShowAudioWaveform: Bool.self,
            
            // MARK: - Camera and image general settings
            .SaveOriginalImage: Bool.self,
            .InputSourceIndex: Int.self,
            
            // MARK: - Sample image settings
            .SampleImageIndex: Int.self,
            .UseLatestBlockCamImage: Bool.self,
            .UseMostRecentImage: Bool.self,
            .ShowUserSamplesOnlyIfAvailable: Bool.self,
            .UserSampleList: String.self,
            .UseSampleImages: Bool.self,
            
            // MARK: - Filter settings.
            .CurrentFilter: String.self,
            .CurrentGroup: String.self,
            .FilterListDisplay: Int.self,
            
            // MARK: - Hue Adjust
            .HueAngle: Double.self,
            
            // MARK: - Kaleidoscope
            .KaleidoscopeSegmentCount: Int.self,
            .KaleidoscopeAngleOfReflection: Int.self,
            .KaleidoscopeFillBackground: Bool.self,
            
            // MARK: - Triangular Kaleidoscope
            .Kaleidoscope3Rotation: Double.self,
            .Kaleidoscope3Size: Double.self,
            .Kaleidoscope3Decay: Double.self,
            
            // MARK: - Mirroring
            .MirrorDirection: Int.self,
            .MirrorLeft: Bool.self,
            .MirrorTop: Bool.self,
            .MirrorQuadrant: Int.self,
            .QuadrantsRotated: Bool.self,
            
            // MARK: - Color Map
            .ColorMapGradient: String.self,
            .ColorMapColor1: UIColor.self,
            .ColorMapColor2: UIColor.self,
            
            // MARK: - Color monochrome map
            .ColorMonochromeColor: UIColor.self,
            
            // MARK: - Bump distortion
            .BumpDistortionRadius: Double.self,
            .BumpDistortionScale: Double.self,
            
            // MARK: - Color controls
            .ColorControlsBrightness: Double.self,
            .ColorControlsContrast: Double.self,
            .ColorControlsSaturation: Double.self,
            
            // MARK: - HSB settings
            .HSBHueValue: Double.self,
            .HSBSaturationValue: Double.self,
            .HSBBrightnessValue: Double.self,
            .HSBChangeBrightness: Bool.self,
            .HSBChangeSaturation: Bool.self,
            .HSBChangeHue: Bool.self,
            
            // MARK: - Circle splash distortion
            .CircleSplashDistortionRadius: Double.self,
            
            // MARK: - Vibrance settings
            .VibranceAmount: Double.self,
            
            // MARK: - CMYK halftone settings
            .CMYKHalftoneWidth: Double.self,
            .CMYKHalftoneSharpness: Double.self,
            .CMYKHalftoneAngle: Double.self,
            
            // MARK: - Dither settings
            .DitherIntensity: Double.self,
            
            // MARK: - Dot screen settings
            .DotScreenWidth: Double.self,
            .DotScreenSharpness: Double.self,
            .DotScreenAngle: Double.self,
            
            // MARK: - Droste settings
            .DrosteZoom: Double.self,
            .DrosteRotation: Double.self,
            .DrosteStrands: Double.self,
            .DrostePeriodicity: Double.self,
            
            // MARK: - Edges settings
            .EdgesIntensity: Double.self,
            
            // MARK: - Exposure value
            .ExposureValue: Double.self,
            
            // MARK: - Unsharp mask
            .UnsharpIntensity: Double.self,
            .UnsharpRadius: Double.self,
            
            // MARK: - Twirl distortion
            .TwirlRadius: Double.self,
            .TwirlAngle: Double.self,
            
            // MARK: - Sepia filter
            .SepiaIntensity: Double.self,
            
            // MARK: - EdgeWork filter
            .EdgeWorkThickness: Double.self,
            
            // MARK: - Threshold filter
            .ThresholdValue: Double.self,
            .ThresholdApplyIfGreater: Bool.self,
            .ThresholdInputChannel: Int.self,
            .ThresholdLowColor: UIColor.self,
            .ThresholdHighColor: UIColor.self,
            
            // MARK: - Convolution filter
            .ConvolutionBias: Double.self,
            .ConvolutionKernel: [[Double]].self,
            .ConvolutionWidth: Int.self,
            .ConvolutionHeight: Int.self,
            .ConvolutionPredefinedKernel: Int.self,
            
            // MARK: - Metal grayscale filter
            .GrayscaleMetalCommand: Int.self,
            .GrayscaleRedMultiplier: Double.self,
            .GrayscaleGreenMultiplier: Double.self,
            .GrayscaleBlueMultiplier: Double.self,
            
            // MARK: - Metal color inversion
            .ColorInverterColorSpace: Int.self,
            .ColorInverterInvertChannel1: Bool.self,
            .ColorInverterInvertChannel2: Bool.self,
            .ColorInverterInvertChannel3: Bool.self,
            .ColorInverterInvertChannel4: Bool.self,
            .ColorInverterEnableChannel1Threshold: Bool.self,
            .ColorInverterEnableChannel2Threshold: Bool.self,
            .ColorInverterEnableChannel3Threshold: Bool.self,
            .ColorInverterEnableChannel4Threshold: Bool.self,
            .ColorInverterChannel1Threshold: Double.self,
            .ColorInverterChannel2Threshold: Double.self,
            .ColorInverterChannel3Threshold: Double.self,
            .ColorInverterChannel4Threshold: Double.self,
            .ColorInverterInvertChannel1IfGreater: Bool.self,
            .ColorInverterInvertChannel2IfGreater: Bool.self,
            .ColorInverterInvertChannel3IfGreater: Bool.self,
            .ColorInverterInvertChannel4IfGreater: Bool.self,
            .ColorInverterInvertAlpha: Bool.self,
            .ColorInverterEnableAlphaThreshold: Bool.self,
            .ColorInverterAlphaThreshold: Double.self,
            .ColorInverterInvertAlphaIfGreater: Bool.self,
            
            // MARK: - Conditional silhouette
            .ConditionalSilhouetteTrigger: Int.self,
            .ConditionalSilhouetteHueThreshold: Double.self,
            .ConditionalSilhouetteHueRange: Double.self,
            .ConditionalSilhouetteSatThreshold: Double.self,
            .ConditionalSilhouetteSatRange: Double.self,
            .ConditionalSilhouetteBriThreshold: Double.self,
            .ConditionalSilhouetteBriRange: Double.self,
            .ConditionalSilhouetteGreaterThan: Bool.self,
            .ConditionalSilhouetteColor: UIColor.self,
            
            // MARK: - Channel mangler
            .ChannelManglerOperation: Int.self,
            
            // MARK: - Channel mixer
            .ChannelMixerChannel1: Int.self,
            .ChannelMixerChannel2: Int.self,
            .ChannelMixerChannel3: Int.self,
            .ChannelMixerInvertChannel1: Bool.self,
            .ChannelMixerInvertChannel2: Bool.self,
            .ChannelMixerInvertChannel3: Bool.self,
            
            // MARK: - Bayer decoding
            .BayerDecodeOrder: Int.self,
            .BayerDecodeMethod: Int.self,
            
            // MARK: - Solarization
            .SolarizeHow: Int.self,
            .SolarizeThresholdLow: Double.self,
            .SolarizeThresholdHigh: Double.self,
            .SolarizeIfGreater: Bool.self,
            .SolarizeLowHue: Double.self,
            .SolarizeHighHue: Double.self,
            .SolarizeBrightnessThresholdLow: Double.self,
            .SolarizeBrightnessThresholdHigh: Double.self,
            .SolarizeSaturationThresholdLow: Double.self,
            .SolarizeSaturationThresholdHigh: Double.self,
            .SolarizeRedThreshold: Double.self,
            .SolarizeGreenThreshold: Double.self,
            .SolarizeBlueThreshold: Double.self,
            .SolarizeOnlyChannel: Bool.self,
            
            // MARK: - Kuwahara
            .KuwaharaRadius: Double.self,
            
            // MARK: - Metal pixellate
            .MetalPixWidth: Int.self,
            .MetalPixHeight: Int.self,
            .MetalPixColorDetermination: Int.self,
            .MetalPixMergeImage: Bool.self,
            .MetalPixHighlightPixel: Int.self,
            .MetalPixThreshold: Double.self,
            .MetalPixInvertThreshold: Bool.self,
            .MetalPixShowBorder: Bool.self,
            .MetalPixBorderColor: UIColor.self,
            
            // MARK: - Twirl bump distortion
            .TwirlBumpTwirlRadius: Double.self,
            .TwirlBumpBumpRadius: Double.self,
            .TwirlBumpAngle: Double.self,
            
            // MARK: - Line screen halftone
            .LineScreenAngle: Double.self,
            
            // MARK: - Smooth linear gradient
            .SmoothLinearColor0: UIColor.self,
            .SmoothLinearColor1: UIColor.self,
        ]
}
