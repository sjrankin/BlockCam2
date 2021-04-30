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
            
            // Filter settings.
            .CurrentFilter: String.self,
            
            // Hue Adjust
            .HueAngle: Double.self,
            
            // Kaleidoscope
            .KaleidoscopeSegmentCount: Int.self,
            .KaleidoscopeAngleOfReflection: Int.self,
            
            // Triangular Kaleidoscope
            .Kaleidoscope3Rotation: Int.self,
            .Kaleidoscope3Size: Int.self,
            .Kaleidoscope3Decay: Double.self,
        ]
}
