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
            
            // Filter settings.
            .CurrentFilter: "",
            .CurrentGroup: "",
            
            // Hue Adjust.
            .HueAngle: 135.0,
            
            // Kaleidoscope.
            .KaleidoscopeSegmentCount: 30,
            .KaleidoscopeAngleOfReflection: 90.0,
            
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
        
            // Color monochrome.
            .ColorMonochromeColor: UIColor.green,
        ]
}
