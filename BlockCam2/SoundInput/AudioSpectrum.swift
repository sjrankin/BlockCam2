//
//  AudioSpectrum.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/17/21.
//

import Foundation
import UIKit
import AVFoundation
import Accelerate

/// Class that holds routines for audio input setup and intialization as well as utility functions for
/// manipulating waveforms.
/// - Note: Must inherit from `NSObject`.
public class AudioSpectrum: NSObject
{
    /// The class that receives waveform information.
     weak var AudioDelegate: AudioProtocol? = nil
    
    /// Initializer.
    override init()
    {
        super.init()
        ConfigureMicrophoneCaptureSession()
        AudioOutput.setSampleBufferDelegate(self, queue: CaptureQueue)
    }
    
    /// Number of bins in each waveform.
    static let WaveformBinCount = 1024
    /// Hop count for skipping data.
    static let HopCount = 512
    /// Capture session for capturing audio input.
    let CaptureSession = AVCaptureSession()
    /// Audio output data.
    let AudioOutput = AVCaptureAudioDataOutput()
    /// Audio capture queue.
    let CaptureQueue = DispatchQueue(label: "AudioCaptureQueue", qos: .userInitiated,
                                     attributes: [], autoreleaseFrequency: .workItem)
    /// Session processing queue.
    let SessionQueue = DispatchQueue(label: "AudioSessionQueue",
                                     attributes: [], autoreleaseFrequency: .workItem)
    /// Discrete cosine transform.
    let ForwardDCT = vDSP.DCT(count: WaveformBinCount, transformType: .II)!
    /// Hanning window for weighted cosines.
    let HanningWindow = vDSP.window(ofType: Float.self,
                                    usingSequence: .hanningNormalized,
                                    count: WaveformBinCount,
                                    isHalfWindow: false)
    /// Semaphore access control.
    let Semaphore = DispatchSemaphore(value: 1)
    
    /// The highest frequency that the app can represent.
    /// The first call of `AudioSpectrogram.captureOutput(_:didOutput:from:)` calculates
    /// this value.
    var nyquistFrequency: Float?
    
    /// A buffer that contains the raw audio data from AVFoundation.
    var RawAudioData = [Int16]()
    
    /// A reusable array that contains the current frame of time domain audio data as single-precision
    /// values.
    var TimeDomainBuffer = [Float](repeating: 0, count: WaveformBinCount)
    
    /// A resuable array that contains the frequency domain representation of the current frame of
    /// audio data.
    var FrequencyDomainBuffer = [Float](repeating: 0, count: WaveformBinCount)
    
    /// Process data from the audio input. The data are transformed into decibels then the delegate is
    /// notified.
    /// - Parameter values: Raw data from audio input.
    func ProcessData(values: [Int16])
    {
        Semaphore.wait()
        
        vDSP.convertElements(of: values, to: &TimeDomainBuffer)
        vDSP.multiply(TimeDomainBuffer, HanningWindow, result: &TimeDomainBuffer)
        ForwardDCT.transform(TimeDomainBuffer, result: &FrequencyDomainBuffer)
        vDSP.absolute(FrequencyDomainBuffer, result: &FrequencyDomainBuffer)
        vDSP.convert(amplitude: FrequencyDomainBuffer,
                     toDecibels: &FrequencyDomainBuffer,
                     zeroReference: Float(AudioSpectrum.WaveformBinCount))
        
        AudioDelegate?.NewWaveform(FrequencyDomainBuffer)
        
        Semaphore.signal()
    }
    
    /// The microphone audio device.
    var CapturedMicrophone: AVCaptureDevice? = nil
    /// The microphone device input.
    var MicrophoneInput: AVCaptureDeviceInput? = nil
}

extension AudioSpectrum: AVCaptureAudioDataOutputSampleBufferDelegate
{
    // MARK: - AudioSpectrum extenstions.
    
    /// Configure the microphone capture session.
    func ConfigureMicrophoneCaptureSession()
    {
        switch AVCaptureDevice.authorizationStatus(for: .audio)
        {
            case .authorized:
                break
                
            case .notDetermined:
                SessionQueue.suspend()
                AVCaptureDevice.requestAccess(for: .audio)
                {
                    Granted in
                    if !Granted
                    {
                        fatalError("Require microphone access.")
                    }
                    else
                    {
                        self.ConfigureMicrophoneCaptureSession()
                        self.SessionQueue.resume()
                    }
                }
                return
                
            default:
                fatalError("Require microphone access.")
        }
        
        CaptureSession.beginConfiguration()
        
        if CaptureSession.canAddOutput(AudioOutput)
        {
            CaptureSession.addOutput(AudioOutput)
        }
        else
        {
            fatalError("Cannot add AudioOutput.")
        }
        
        CapturedMicrophone = AVCaptureDevice.default(.builtInMicrophone,
                                                     for: .audio,
                                                     position: .unspecified)
        if CapturedMicrophone == nil
        {
            fatalError("Error getting microphone")
        }
        MicrophoneInput = try? AVCaptureDeviceInput(device: CapturedMicrophone!)
        if MicrophoneInput == nil
        {
            fatalError("Error getting microphone input")
        }
        if CaptureSession.canAddInput(MicrophoneInput!)
        {
            CaptureSession.addInput(MicrophoneInput!)
        }
        else
        {
            fatalError("Error adding microphone input")
        }
        CaptureSession.commitConfiguration()
    }
    
    /// Called when data is available from the captured audio device.
    /// - Parameter output: Not used.
    /// - Parameter sampleBuffer: The buffer of sampled audio data.
    /// - Parameter connection: Not used.
    public func captureOutput(_ output: AVCaptureOutput,
                              didOutput sampleBuffer: CMSampleBuffer,
                              from connection: AVCaptureConnection)
    {
        var BufferList = AudioBufferList()
        var BlockBuffer: CMBlockBuffer?
        
        CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer,
                                                                bufferListSizeNeededOut: nil,
                                                                bufferListOut: &BufferList,
                                                                bufferListSize: MemoryLayout.stride(ofValue: BufferList),
                                                                blockBufferAllocator: nil,
                                                                blockBufferMemoryAllocator: nil,
                                                                flags: kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment,
                                                                blockBufferOut: &BlockBuffer)
        guard let data = BufferList.mBuffers.mData else
        {
            print("Error getting data from buffer list")
            return
        }
        
        if nyquistFrequency == nil
        {
            let Duration = Float(CMSampleBufferGetDuration(sampleBuffer).value)
            let TimeScale = Float(CMSampleBufferGetDuration(sampleBuffer).timescale)
            let NumSamples = Float(CMSampleBufferGetNumSamples(sampleBuffer))
            nyquistFrequency = 0.5 / (Duration / TimeScale / NumSamples)
        }
        
        if RawAudioData.count < AudioSpectrum.WaveformBinCount * 2
        {
            let ActualSampleCount = CMSampleBufferGetNumSamples(sampleBuffer)
            let Ptr = data.bindMemory(to: Int16.self, capacity: ActualSampleCount)
            let Buf = UnsafeBufferPointer(start: Ptr, count:ActualSampleCount)
            RawAudioData.append(contentsOf: Array(Buf))
        }
        
        while RawAudioData.count >= AudioSpectrum.WaveformBinCount
        {
            let DataToProcess = Array(RawAudioData[0 ..< AudioSpectrum.WaveformBinCount])
            self.RawAudioData.removeFirst(AudioSpectrum.HopCount)
            self.ProcessData(values: DataToProcess)
        }
    }
    
    /// Start running the audio capturing queue.
    func StartRunning()
    {
        SessionQueue.async
        {
            if AVCaptureDevice.authorizationStatus(for: .audio) == .authorized
            {
                self.CaptureSession.startRunning()
            }
        }
    }
}
