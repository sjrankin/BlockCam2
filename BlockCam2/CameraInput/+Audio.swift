//
//  +Audio.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/20/21.
//

import Foundation
import UIKit
import SceneKit
import CoreImage

extension LiveViewController
{
    // MARK: - Audio initialization.
    
    /// Initialize the audio processor and start it running.
    func InitializeAudio()
    {
        Microphone = AudioProcessor(SampleCount: LiveViewController.AccumulationCount,
                                    BinCount: LiveViewController.MicrophoneBinCount)
        Microphone?.AudioDelegate = self
        Microphone?.StartRunning()
    }
    
    // MARK: - Audio waveform functions.
    
    /// Handle new waveform data.
    /// - Parameter Waveform: Array of `Float`s of waveform data.
    func NewWaveform(_ Waveform: [Float])
    {
        OperationQueue.main.addOperation
        {
            if let Final = self.Microphone?.PrepareWaveform(Waveform, WindowSize: LiveViewController.RollingMeanWindowSize)
            {
                self.DrawHistogram(Final)
            }
        }
    }
    
    /// Draw a histogram of the passed waveform.
    /// - Note: The histogram is drawn on a `CAShapeLayer` and inserted at the top of the z order over the
    ///         live view.
    /// - Parameter Raw: The raw histogram data to draw.
    func DrawHistogram(_ Raw: [CGFloat])
    {
        if Raw.isEmpty
        {
            fatalError("raw is empty")
        }
        
        if !HistogramInitialized
        {
            HistogramInitialized = true
            HistogramLayer = CAShapeLayer()
            HistogramLayer.frame = self.view.bounds
            HistogramLayer.backgroundColor = UIColor.clear.cgColor
            HistogramLayer.zPosition = 100000
            view.layer.addSublayer(self.HistogramLayer)
        }
        HistogramLayer.sublayers = nil
        let CenterY = HistogramLayer.frame.height / 2.0
        let Multiplier: CGFloat = 400.0
        var X: CGFloat = 5.0
        let XIncrement = (HistogramLayer.frame.width - 10.0) / CGFloat(Raw.count)
        let MainShape = UIBezierPath()
        var YValue = CenterY - (Raw.first! * Multiplier)
        if YValue.isInfinite
        {
            YValue = 0.0
        }
        MainShape.move(to: CGPoint(x: X, y: YValue))
        var count = 0
        for DB in Raw
        {
            let FinalDB = DB * Multiplier
            var YValue = CenterY - FinalDB
            if YValue.isInfinite
            {
                YValue = 0.0
            }
            MainShape.addLine(to: CGPoint(x: X, y: YValue))
            X = X + XIncrement
            count = count + 1
        }
        MainShape.move(to: CGPoint(x: 5.0, y: CenterY))
        MainShape.addLine(to: CGPoint(x: HistogramLayer.frame.width - 5.0, y: CenterY))
        HistogramLayer.fillColor = UIColor.clear.cgColor
        HistogramLayer.lineJoin = .round
        HistogramLayer.lineWidth = 2.0
        HistogramLayer.strokeColor = UIColor.systemTeal.cgColor
        HistogramLayer.path = MainShape.cgPath
        callcount = callcount + 1
    }
}
