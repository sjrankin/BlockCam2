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
            // Infrastructure/initialization-related settings.
            .InitializationFlag: false,
            .InstanceID: "",
            
            // User interface settings.
            .ShowAudioWaveform: false,
            .SaveOriginalImage: true,
            .SampleImageIndex: 0,
            .InputSourceIndex: 0,
            
            // Filter settings.
            .CurrentFilter: "",
            .CurrentGroup: "",
            
            // Hue Adjust.
            .HueAngle: 135.0,
            
            // Kaleidoscope.
            .KaleidoscopeSegmentCount: 30,
            .KaleidoscopeAngleOfReflection: 90,
            .KaleidoscopeFillBackground: true,
            
            // Triangular Kaleidoscope.
            .Kaleidoscope3Rotation: 0.0,
            .Kaleidoscope3Size: 200.0,
            .Kaleidoscope3Decay: 1.0,
            
            // Mirroring.
            .MirrorDirection: 0,
            .MirrorLeft: true,
            .MirrorTop: true,
            .MirrorQuadrant: 1,
            .QuadrantsRotated: true,
            
            // Color Map.
            .ColorMapGradient: "(White)@(0.0),(Black)@(1.0)",
            .ColorMapColor1: UIColor.white,
            .ColorMapColor2: UIColor.black,
        
            // Color monochrome.
            .ColorMonochromeColor: UIColor.green,
            
            // Bump distortion.
            .BumpDistortionRadius: 200.0,
            .BumpDistortionScale: 0.65,
            
            // Color controls.
            .ColorControlsBrightness: 0.0,
            .ColorControlsContrast: 0.0,
            .ColorControlsSaturation: 0.0,
            
            // HSB settings
            .HSBHueValue: 1.0,
            .HSBSaturationValue: 1.0,
            .HSBBrightnessValue: 1.0,
            .HSBChangeBrightness: true,
            .HSBChangeSaturation: true,
            .HSBChangeHue: true,
            
            // Circle splash distortions
            .CircleSplashDistortionRadius: 350.0,
            
            // Vibrance settings
            .VibranceAmount: 2.0,
            
            // CMYK halftone settings
            .CMYKHalftoneWidth: 6.0,
            .CMYKHalftoneSharpness: 0.7,
            .CMYKHalftoneAngle: 90.0,
            
            // Dither settings
            .DitherIntensity: 3.5,
            
            // Dot screen settings
            .DotScreenWidth: 6.0,
            .DotScreenSharpness: 0.7,
            .DotScreenAngle: 90.0,
            
            // Droste settings
            .DrosteRotation: 35.0,
            .DrosteStrands: 20.0,
            .DrosteZoom: 1.0,
            .DrostePeriodicity: 2.0,
            
            // Edges settings
            .EdgesIntensity: 50.0,
            
            // Exposure settings
            .ExposureValue: 1.0,
            
            // Unsharp mask settings
            .UnsharpIntensity: 1.0,
            .UnsharpRadius: 1.0,
            
            // Twirl distortion settings
            .TwirlRadius: 50.0,
            .TwirlAngle: 0.0,
            
            // Sepia filter
            .SepiaIntensity: 0.55,
            
            // EdgeWork filter
            .EdgeWorkThickness: 0.1,
        ]
}
