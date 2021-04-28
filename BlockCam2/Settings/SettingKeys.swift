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
}
