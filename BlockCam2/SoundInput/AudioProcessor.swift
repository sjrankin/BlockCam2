//
//  AudioProcessor.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/18/21.
//

import Foundation
import UIKit

/// Manages input from an audio source. Provides some data manipulation functions.
class AudioProcessor
{
    /// Initializer.
    /// - Note: `StartRunning` must be called after setting the `AudioDelegate` or
    ///         no data will be returned.
    /// - Warning: If `SampleCount` or `BinCount` is less than 1, a fatal error is thrown.
    /// - Parameter SampleCount: Number of samples to accumulate before reporting data. Defaults to `10`.
    /// - Parameter BinCount: Number of bins per sample. Defaults to `256`.
    init(SampleCount: Int = 10, BinCount: Int = 256)
    {
        if SampleCount < 1
        {
            fatalError("Invalid sample count (\(SampleCount) - must be 1 or greater.")
        }
        if BinCount < 1
        {
            fatalError("Invalid bin count (\(BinCount) - must be 1 or greater.")
        }
        Spectrum = AudioSpectrum()
        _MaxSampleCount = SampleCount
        _BinCount = BinCount
        AccumulatedWaves = Array(repeating: Array(repeating: 0.0, count: BinCount), count: SampleCount)
    }
    
    /// Holds the sample count.
    private var _MaxSampleCount: Int = 10
    /// The number of samples accumulated before returning data.
    public var MaxSampleCount: Int
    {
        get
        {
            return _MaxSampleCount
        }
    }
    
    /// Holds the bin count.
    private var _BinCount: Int = 256
    /// Number of bins per sample.
    public var BinCount: Int
    {
        get
        {
            return _BinCount
        }
    }
    
    /// Called when data is ready for the parent.
    weak var AudioDelegate: AudioProtocol? = nil
    {
        didSet
        {
            Spectrum?.AudioDelegate = AudioDelegate
        }
    }
    
    /// Holds the audio spectrum class.
    var Spectrum: AudioSpectrum? = nil
    
    /// Start running the audio spectrum analyzer. If not called, no data is
    /// returned.
    func StartRunning()
    {
        Spectrum?.StartRunning()
    }
    
    /// Synchronization gate for calculating rolling means.
    private static var MeanGate = NSObject()
    
    /// Returns an array of rolling mean values calculated from the source array.
    /// - Warning: If `WindowSize` is less than `1`, a fatal error is thrown.
    /// - Parameter For: Source data whose rolling mean values will be calculated.
    /// - Parameter WindowSize: Size of the rolling mean window. If `1` is passed, the
    ///                         original array is returned without modification.
    public static func RollingMean(For: [CGFloat], WindowSize: Int) -> [CGFloat]
    {
        if WindowSize < 1
        {
            fatalError("WindowSize must be 1 or greater.")
        }
        objc_sync_enter(MeanGate)
        defer{objc_sync_exit(MeanGate)}
        if WindowSize == 1
        {
            return For
        }
        var Result = [CGFloat]()
        for Index in 0 ..< For.count
        {
            let Start = Index
            let End = Start + WindowSize
            if End >= For.count - 1
            {
                return Result
            }
            var Accumulator: CGFloat = 0.0
            for MeanIndex in Start ..< End
            {
                Accumulator = Accumulator + For[MeanIndex]
            }
            Result.append(Accumulator / CGFloat(WindowSize))
        }
        return Result
    }
    
    /// Waveform preparation synchornization gate.
    private var PrepareGate = NSObject()
    
    /// Prepare a waveform for use by the user interface.
    /// - Note: Raw decibel values range from `-160` to `-1` as per Apple documentation.
    /// - Note: The steps taken to prepare the wave are:
    ///   1. Convert the values to positive normal values.
    ///   2. Reduce the amount of items as per the `ReduceBy` parameter.
    ///   3. Reverse the array.
    ///   4. Accumulate the array in the wave accumulator.
    ///   5. If the number of accumulated waves is equal to or greater than the
    ///      sample size (set in the initializer), take the mean of each bin and
    ///      save it in a new array.
    ///   6. Apply a rolling mean to the new array.
    ///   7. Return the new array.
    /// - Warning:
    ///   - If `ReduceBy` is less than `1`, a fatal error is thrown.
    ///   - If `WindowSize` is less than `1`, a fatal error is thrown.
    /// - Parameter Raw: Raw waveform data in units of decibels.
    /// - Parameter WindowSize: Rolling mean window size. Must be `1` or greater. If this
    ///                         value is `1`, no rolling mean is calculated. (Chronologic
    ///                         means will still be calculated.)
    /// - Parameter ReduceBy: How to reduce the original array to a smaller array. The value
    ///                       passed here determines which items are included in the final
    ///                       array - for example, if `ReduceBy` is `4`, every fourth item
    ///                       from the original array is added to the reduced array. if `ReduceBy`
    ///                       is `6`, every sixth item is included. If this value is `1`, no
    ///                       array reduction occurs.
    /// - Returns: Prepared waveform according to the steps in the notes..
    public func PrepareWaveform(_ Raw: [Float], WindowSize: Int, ReduceBy: Int = 4) -> [CGFloat]?
    {
        objc_sync_enter(PrepareGate)
        defer{objc_sync_exit(PrepareGate)}
        if ReduceBy < 1
        {
            fatalError("ReduceBy must be 1 or greater.")
        }
        if WindowSize < 1
        {
            fatalError("WindowSize must be 1 or greater.")
        }
        WaveformCount = WaveformCount + 1
        let Normalized = Raw.compactMap({CGFloat(abs($0) / 160.0)})
        var ReducedData = [CGFloat]()
        if ReduceBy == 1
        {
            ReducedData = Normalized
        }
        else
        {
            for Index in 0 ..< Normalized.count
            {
                if Index.isMultiple(of: ReduceBy)
                {
                    ReducedData.append(Normalized[Index])
                }
            }
        }
        ReducedData.reverse()
        AccumulatedWaves[MeanIndex] = ReducedData
        MeanIndex = (MeanIndex + 1) % MaxSampleCount
        if WaveformCount >= MaxSampleCount
        {
            var FinalMeaned = [CGFloat](repeating: 0.0, count: BinCount)
            for x in 0 ..< MaxSampleCount
            {
                for y in 0 ..< BinCount
                {
                    FinalMeaned[y] = FinalMeaned[y] + AccumulatedWaves[x][y]
                }
            }
            FinalMeaned = FinalMeaned.map({$0 / CGFloat(MaxSampleCount)})
            let Rolling = AudioProcessor.RollingMean(For: FinalMeaned, WindowSize: WindowSize)
            return Rolling
        }
        else
        {
            return nil
        }
    }
    
    private var WaveformCount: Int = 0
    private var MeanIndex: Int = 0
    private var AccumulatedWaves = [[CGFloat]]()
}
