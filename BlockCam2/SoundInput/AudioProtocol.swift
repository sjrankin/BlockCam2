//
//  AudioProtocol.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/17/21.
//

import Foundation

/// Protocol for communicating from the audio class to the parent class.
protocol AudioProtocol: AnyObject
{
    /// New waveform available from the hardware.
    func NewWaveform(_ Waveform: [Float])
}
