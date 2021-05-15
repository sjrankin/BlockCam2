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
            // Infrastructure/initialization-related settings.
            .InitializationFlag: Bool.self,
            .InstanceID: String.self,
            
            // User interface settings.
            .ShowAudioWaveform: Bool.self,
            .SaveOriginalImage: Bool.self,
            .SampleImageIndex: Int.self,
            .InputSourceIndex: Int.self,
            
            // Filter settings.
            .CurrentFilter: String.self,
            .CurrentGroup: String.self,
            
            // Hue Adjust
            .HueAngle: Double.self,
            
            // Kaleidoscope
            .KaleidoscopeSegmentCount: Int.self,
            .KaleidoscopeAngleOfReflection: Int.self,
            .KaleidoscopeFillBackground: Bool.self,
            
            // Triangular Kaleidoscope
            .Kaleidoscope3Rotation: Double.self,
            .Kaleidoscope3Size: Double.self,
            .Kaleidoscope3Decay: Double.self,
            
            // Mirroring
            .MirrorDirection: Int.self,
            .MirrorLeft: Bool.self,
            .MirrorTop: Bool.self,
            .MirrorQuadrant: Int.self,
            .QuadrantsRotated: Bool.self,
            
            // Color Map
            .ColorMapGradient: String.self,
            .ColorMapColor1: UIColor.self,
            .ColorMapColor2: UIColor.self,
            
            // Color monochrome map
            .ColorMonochromeColor: UIColor.self,
            
            // Bump distortion
            .BumpDistortionRadius: Double.self,
            .BumpDistortionScale: Double.self,
            
            // Color controls
            .ColorControlsBrightness: Double.self,
            .ColorControlsContrast: Double.self,
            .ColorControlsSaturation: Double.self,
            
            // HSB settings
            .HSBHueValue: Double.self,
            .HSBSaturationValue: Double.self,
            .HSBBrightnessValue: Double.self,
            .HSBChangeBrightness: Bool.self,
            .HSBChangeSaturation: Bool.self,
            .HSBChangeHue: Bool.self,
            
            // Circle splash distortion
            .CircleSplashDistortionRadius: Double.self,
            
            // Vibrance settings
            .VibranceAmount: Double.self,
            
            // CMYK halftone settings
            .CMYKHalftoneWidth: Double.self,
            .CMYKHalftoneSharpness: Double.self,
            .CMYKHalftoneAngle: Double.self,
            
            // Dither settings
            .DitherIntensity: Double.self,
            
            // Dot screen settings
            .DotScreenWidth: Double.self,
            .DotScreenSharpness: Double.self,
            .DotScreenAngle: Double.self,
            
            // Droste settings
            .DrosteZoom: Double.self,
            .DrosteRotation: Double.self,
            .DrosteStrands: Double.self,
            .DrostePeriodicity: Double.self,
            
            // Edges settings
            .EdgesIntensity: Double.self,
            
            // Exposure value
            .ExposureValue: Double.self,
            
            // Unsharp mask
            .UnsharpIntensity: Double.self,
            .UnsharpRadius: Double.self,
            
            // Twirl distortion
            .TwirlRadius: Double.self,
            .TwirlAngle: Double.self,
            
            // Sepia filter
            .SepiaIntensity: Double.self,
            
            // EdgeWork filter
            .EdgeWorkThickness: Double.self,
            
            /// Threshold filter
            .ThresholdValue: Double.self,
            .ThresholdApplyIfGreater: Bool.self,
            .ThresholdInputChannel: Int.self,
            .ThresholdLowColor: UIColor.self,
            .ThresholdHighColor: UIColor.self,
            
            /// Convolution filter
            .ConvolutionBias: Double.self,
            .ConvolutionKernel: [[Double]].self,
            .ConvolutionWidth: Int.self,
            .ConvolutionHeight: Int.self,
            .ConvolutionPredefinedKernel: Int.self,
        ]
}
