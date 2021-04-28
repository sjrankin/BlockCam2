//
//  SettingsUI.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/28/21.
//

import Foundation
import SwiftUI

/// Wrapper around the non-SwiftUI Settings manager class to provide access to settings.
class SettingsUI: ObservableObject
{
    /// Get or set the show audio waveform flag.
    @Published var ShowAudioWaveform: Bool = Settings.GetBool(.ShowAudioWaveform)
    {
        didSet
        {
            Settings.SetBool(.ShowAudioWaveform, self.ShowAudioWaveform)
        }
    }
    
    /// Get or set the save original image with filtered image flag.
    @Published var SaveOriginalImage: Bool = Settings.GetBool(.SaveOriginalImage)
    {
        didSet
        {
            Settings.SetBool(.SaveOriginalImage, self.SaveOriginalImage)
        }
    }
    
    /// Get or set the current filter name.
    @Published var CurrentFilter: String = Settings.GetString(.CurrentFilter, "Passthrough")
    {
        didSet
        {
            Settings.SetString(.CurrentFilter, self.CurrentFilter)
        }
    }
}
