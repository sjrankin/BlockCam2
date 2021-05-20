//
//  SettingDefaults.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/4/21.
//

import Foundation
import UIKit

extension Settings
{
    public static let SettingDefaults: [SettingKeys: Any] =
        [
            // MARK: - Infrastructure/initialization-related settings
            .InitializationFlag: false,
            .InstanceID: "",
            
            // MARK: - Audio settings
            .ShowAudioWaveform: false,
            
            // MARK: - Camera and image general settings.
            .SaveOriginalImage: true,
            .InputSourceIndex: 0,
            
            // MARK: - Sample images
            .SampleImageIndex: 0,
            .UseLatestBlockCamImage: false,
            .UseMostRecentImage: false,
            .ShowUserSamplesOnlyIfAvailable: false,
            
            // MARK: - Filter settings.
            .CurrentFilter: "",
            .CurrentGroup: "",
            
            // MARK: - Hue Adjust.
            .HueAngle: 135.0,
            
            // MARK: - Kaleidoscope.
            .KaleidoscopeSegmentCount: 30,
            .KaleidoscopeAngleOfReflection: 90,
            .KaleidoscopeFillBackground: true,
            
            // MARK: - Triangular Kaleidoscope.
            .Kaleidoscope3Rotation: 0.0,
            .Kaleidoscope3Size: 200.0,
            .Kaleidoscope3Decay: 1.0,
            
            // MARK: - Mirroring.
            .MirrorDirection: 0,
            .MirrorLeft: true,
            .MirrorTop: true,
            .MirrorQuadrant: 1,
            .QuadrantsRotated: true,
            
            // MARK: - Color Map.
            .ColorMapGradient: "(White)@(0.0),(Black)@(1.0)",
            .ColorMapColor1: UIColor.white,
            .ColorMapColor2: UIColor.black,
            
            // MARK: - Color monochrome.
            .ColorMonochromeColor: UIColor.green,
            
            // MARK: - Bump distortion.
            .BumpDistortionRadius: 200.0,
            .BumpDistortionScale: 0.65,
            
            // MARK: - Color controls.
            .ColorControlsBrightness: 0.0,
            .ColorControlsContrast: 0.0,
            .ColorControlsSaturation: 0.0,
            
            // MARK: - HSB settings
            .HSBHueValue: 1.0,
            .HSBSaturationValue: 1.0,
            .HSBBrightnessValue: 1.0,
            .HSBChangeBrightness: true,
            .HSBChangeSaturation: true,
            .HSBChangeHue: true,
            
            // MARK: - Circle splash distortions
            .CircleSplashDistortionRadius: 350.0,
            
            // MARK: - Vibrance settings
            .VibranceAmount: 2.0,
            
            // MARK: - CMYK halftone settings
            .CMYKHalftoneWidth: 6.0,
            .CMYKHalftoneSharpness: 0.7,
            .CMYKHalftoneAngle: 90.0,
            
            // MARK: - Dither settings
            .DitherIntensity: 3.5,
            
            // MARK: - Dot screen settings
            .DotScreenWidth: 6.0,
            .DotScreenSharpness: 0.7,
            .DotScreenAngle: 90.0,
            
            // MARK: - Droste settings
            .DrosteRotation: 35.0,
            .DrosteStrands: 20.0,
            .DrosteZoom: 1.0,
            .DrostePeriodicity: 2.0,
            
            // MARK: - Edges settings
            .EdgesIntensity: 50.0,
            
            // MARK: - Exposure settings
            .ExposureValue: 1.0,
            
            // MARK: - Unsharp mask settings
            .UnsharpIntensity: 1.0,
            .UnsharpRadius: 1.0,
            
            // MARK: - Twirl distortion settings
            .TwirlRadius: 50.0,
            .TwirlAngle: 0.0,
            
            // MARK: - Sepia filter
            .SepiaIntensity: 0.55,
            
            // MARK: - EdgeWork filter
            .EdgeWorkThickness: 0.1,
            
            // MARK: - Threshold filter
            .ThresholdValue: 0.4,
            .ThresholdApplyIfGreater: false,
            .ThresholdInputChannel: 0,
            .ThresholdLowColor: UIColor.black,
            .ThresholdHighColor: UIColor.yellow,
            
            // MARK: - Convolution filter
            .ConvolutionBias: 0.0,
            .ConvolutionKernel: [
                [1.0, 0.0, 0.0, 0.0, 0.0],
                [0.0, 1.0, 0.0, 0.0, 0.0],
                [0.0, 0.0, 1.0, 0.0, 0.0],
                [0.0, 0.0, 0.0, 1.0, 0.0],
                [0.0, 0.0, 0.0, 0.0, 1.0],
            ],
            .ConvolutionWidth: 3,
            .ConvolutionHeight: 3,
            .ConvolutionPredefinedKernel: 0,
            
            // MARK: - Grayscale metal filter
            .GrayscaleMetalCommand: 0,
            .GrayscaleRedMultiplier: 0.5,
            .GrayscaleGreenMultiplier: 0.5,
            .GrayscaleBlueMultiplier: 0.5,
            
            // MARK: - Metal color inversion
            .ColorInverterColorSpace: 0,
            .ColorInverterInvertChannel1: false,
            .ColorInverterInvertChannel2: false,
            .ColorInverterInvertChannel3: false,
            .ColorInverterInvertChannel4: false,
            .ColorInverterEnableChannel1Threshold: false,
            .ColorInverterEnableChannel2Threshold: false,
            .ColorInverterEnableChannel3Threshold: false,
            .ColorInverterEnableChannel4Threshold: false,
            .ColorInverterChannel1Threshold: 0.5,
            .ColorInverterChannel2Threshold: 0.5,
            .ColorInverterChannel3Threshold: 0.5,
            .ColorInverterChannel4Threshold: 0.5,
            .ColorInverterInvertChannel1IfGreater: false,
            .ColorInverterInvertChannel2IfGreater: false,
            .ColorInverterInvertChannel3IfGreater: false,
            .ColorInverterInvertChannel4IfGreater: false,
            .ColorInverterInvertAlpha: false,
            .ColorInverterEnableAlphaThreshold: false,
            .ColorInverterAlphaThreshold: 0.5,
            .ColorInverterInvertAlphaIfGreater: false,
            
            // MARK: - Conditional silhouette
            .ConditionalSilhouetteTrigger: 0,
            .ConditionalSilhouetteHueThreshold: 0.5,
            .ConditionalSilhouetteHueRange: 0.3,
            .ConditionalSilhouetteSatThreshold: 0.5,
            .ConditionalSilhouetteSatRange: 0.3,
            .ConditionalSilhouetteBriThreshold: 0.5,
            .ConditionalSilhouetteBriRange: 0.3,
            .ConditionalSilhouetteGreaterThan: false,
            .ConditionalSilhouetteColor: UIColor.black,
            
            // MARK: - Channel mangler
            .ChannelManglerOperation: 0,
            
            // MARK: - Channel mixer
            .ChannelMixerChannel1: 0,
            .ChannelMixerChannel2: 1,
            .ChannelMixerChannel3: 2,
            .ChannelMixerInvertChannel1: false,
            .ChannelMixerInvertChannel2: false,
            .ChannelMixerInvertChannel3: false,
            
            // MARK: - Bayer decoding
            .BayerDecodeOrder: 0,
            .BayerDecodeMethod: 0,
            
            // MARK: - Solarization
            .SolarizeHow: 0,
            .SolarizeThresholdLow: 0.5,
            .SolarizeThresholdHigh: 0.5,
            .SolarizeIfGreater: false,
            .SolarizeLowHue: 90.0,
            .SolarizeHighHue: 270.0,
            .SolarizeBrightnessThresholdLow: 0.5,
            .SolarizeBrightnessThresholdHigh: 0.5,
            .SolarizeSaturationThresholdLow: 0.5,
            .SolarizeSaturationThresholdHigh: 0.5,
            .SolarizeRedThreshold: 0.5,
            .SolarizeGreenThreshold: 0.5,
            .SolarizeBlueThreshold: 0.5,
            .SolarizeOnlyChannel: false,
            
            // MARK: - Kuwahara
            .KuwaharaRadius: 0.1,
            
            // MARK: - Metal pixellate
            .MetalPixWidth: 24,
            .MetalPixHeight: 24,
            .MetalPixColorDetermination: 0,
            .MetalPixMergeImage: false,
            .MetalPixHighlightPixel: 3,
            .MetalPixThreshold: 0.5,
            .MetalPixInvertThreshold: false,
            .MetalPixShowBorder: false,
            .MetalPixBorderColor: UIColor.black,
        ]
}
