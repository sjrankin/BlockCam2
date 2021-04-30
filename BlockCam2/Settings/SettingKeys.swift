//
//  SettingKeys.swift
//  BlockCam2
//  Adapted from FlatlandView, 5/24/20.
//
//  Created by Stuart Rankin on 4/27/21.
//

import Foundation

/// Settings. Each case refers to a single setting and is used
/// by the settings class to access the setting.
enum SettingKeys: String, CaseIterable
{
    // MARK: - Infrastructure/initialization-related settings.
    
    case InitializationFlag = "InitializationFlag"
    case InstanceID = "InstanceID"
    
    // MARK: - User interface settings.
    
    /// Boolean: If true, audio waveforms are shown overlayed the image.
    case ShowAudioWaveform = "ShowAudioWaveform"
    /// Boolean: If true, the original image is saved along with the modified image.
    case SaveOriginalImage = "SaveOriginalImage"
    
    // MARK: - Filter settings.
    /// String: Current filter in use.
    case CurrentFilter = "CurrentFilter"
    
    // - MARK: Hue Adjust
    /// Double: The angle of the hue for Hue Adjust
    case HueAngle = "HueAngle"
    
    // - MARK: Kaleidoscope
    /// Int: Number of segments for the kaleidoscope.
    case KaleidoscopeSegmentCount = "KaleidoscopeSegmentCount"
    /// Int: Angle of reflection for the kaleidoscope.
    case KaleidoscopeAngleOfReflection = "KaleidoscopeAngleOfReflection"

    // - MARK: Triangular Kaleidoscope
    /// Int: Angle of rotation.
    case Kaleidoscope3Rotation = "Kaleidoscope3Rotation"
    /// Int: Size of triangles.
    case Kaleidoscope3Size = "Kaleidoscope3Size"
    /// Double: Color decay from center to edge.
    case Kaleidoscope3Decay = "Kaleidoscope3Decay"
}
