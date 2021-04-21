//
//  MicrophoneInput.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/16/21.
//

import Foundation
import AVFoundation

/// The microphone input device.
class MicrophoneInput: ObservableObject
{
    /// Current number of bins in a sample.
    private var BinCount: Int = 0
    /// The audio recorder device.
    private var Recorder: AVAudioRecorder!
    /// Binned samples array.
    @Published public var BinnedSamples = [Float]()
    /// Current bin.
    private var CurrentBin: Int = 0
    /// Sample retrieval timer.
    private var SampleTimer: Timer?
    
    /// Initializer.
    /// - Warning: If `BinCount` is `0` or less, a fatal error is thrown.
    /// - Parameter BinCount: Number of bins per sample.
    init(BinCount: Int)
    {
        guard BinCount > 0 else
        {
            fatalError("Bin count must be greater than 0.")
        }
        self.BinCount = BinCount
        CurrentBin = 0
        BinnedSamples = [Float](repeating: 0.0, count: self.BinCount)
        
        let AudioSession = AVAudioSession.sharedInstance()
        if AudioSession.recordPermission != .granted
        {
            AudioSession.requestRecordPermission
            {
                Granted in
                if !Granted
                {
                    fatalError("Must have permission for audio recording.")
                }
            }
        }
        
        let DevNull = URL(fileURLWithPath: "/dev/null", isDirectory: true)
        let AudioSettings: [String: Any] =
        [
            AVFormatIDKey: NSNumber(value: kAudioFormatAppleLossless),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue,
        ]
        do
        {
            Recorder = try AVAudioRecorder(url: DevNull, settings: AudioSettings)
            try AudioSession.setCategory(.playAndRecord, mode: .default, options: [])
        }
        catch
        {
            fatalError(error.localizedDescription)
        }
    }
    
    /// Audio engine used to listen to the microphone.
    //var Engine: AVAudioEngine!
    
    /// Deinitialize. Stop the timer and listening to the microphone.
    deinit
    {
        SampleTimer?.invalidate()
        Recorder.stop()
    }
    
    /// Start listening to the microphone.
    /// - Parameter Interval: How often to get audio sample data, in seconds. Defaults to `0.01`.
    /// - Parameter Block: Closure that receives sampled data from the microphone synchronously.
    public func StartListening(_ Interval: Double = 0.01, _ Block: (([Float]) -> ())? = nil)
    {
        Recorder.isMeteringEnabled = true
        Recorder.record()
        SampleTimer = Timer.scheduledTimer(withTimeInterval: Interval, repeats: true)
        {
            _ in
            self.Recorder.updateMeters()
            self.BinnedSamples[self.CurrentBin] = self.Recorder.peakPower(forChannel: 0)
            self.CurrentBin = (self.CurrentBin + 1) % self.BinCount
            Block?(self.BinnedSamples)
        }
    }
}
