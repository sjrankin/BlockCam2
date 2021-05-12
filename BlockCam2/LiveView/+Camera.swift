//
//  +Camera.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/20/21.
//

import Foundation
import UIKit
import SceneKit
import AVFoundation
import CoreImage
import CoreServices
import AVKit
import Photos
import MobileCoreServices
import CoreMotion

extension LiveViewController
{
    //MARK: - Camera-related functionality.
    
    /// Switch cameras (from front to rear or rear to front).
    /// - Note: If running on a simulator, control returns immediately.
    func DoSwitchCameras()
    {
        #if targetEnvironment(simulator)
        print("On simulator - no cameras to switch.")
        return
        #else
        DataOutputQueue.sync
        {
            //disable rendering here
            self.VideoDepthMixer.reset()
            self.CurrentDepthPixelBuffer = nil
            self.VideoDepthConverter.reset()
            self.MetalView!.pixelBuffer = nil
        }
        ProcessingQueue.sync
        {
            self.PhotoDepthMixer.reset()
            self.PhotoDepthConverter.reset()
        }
        let InterfaceOrientation = StatusBarOrientation
        SessionQueue.async
        {
            let CurrentDevice = self.VideoDeviceInput.device
            let CurrentPhotoOrientation = self.PhotoOutput.connection(with: .video)?.videoOrientation
            var PreferredPosition = AVCaptureDevice.Position.unspecified
            switch CurrentDevice.position
            {
                case .unspecified:
                    fallthrough
                    
                case .front:
                    PreferredPosition = .back
                    
                case .back:
                    PreferredPosition = .front
            }
            let Devices = self.VideoDeviceDiscoverySession.devices
            if let PreferredDevice = Devices.first(where: {$0.position == PreferredPosition})
            {
                var VidInput: AVCaptureDeviceInput
                do
                {
                    VidInput = try AVCaptureDeviceInput(device: PreferredDevice)
                }
                catch
                {
                    print("Error creating video device during camera switch: \(error.localizedDescription)")
                    return
                }
                self.CaptureSession.beginConfiguration()
                self.CaptureSession.removeInput(self.VideoDeviceInput)
                if self.CaptureSession.canAddInput(VidInput)
                {
                    NotificationCenter.default.removeObserver(self,
                                                              name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange,
                                                              object: CurrentDevice)
                    NotificationCenter.default.addObserver(self,
                                                           selector: #selector(self.SubjectAreaChanged),
                                                           name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange,
                                                           object: CurrentDevice)
                    self.CaptureSession.addInput(VidInput)
                    self.VideoDeviceInput = VidInput
                }
                else
                {
                    print("Could not add video to device input during camera switch operation.")
                    self.CaptureSession.addInput(self.VideoDeviceInput)
                }
                
                self.PhotoOutput.connection(with: .video)!.videoOrientation = CurrentPhotoOrientation!
                
                self.CaptureSession.commitConfiguration()
            }
            let VideoPosition = self.VideoDeviceInput.device.position
            let VideoOrientation = self.VideoDataOutput.connection(with: .video)!.videoOrientation
            let VidRotation = LiveMetalView.ViewRotations(with: InterfaceOrientation,
                                                          videoOrientation: VideoOrientation,
                                                          cameraPosition: VideoPosition)
            self.MetalView?.Mirroring = VideoPosition == .front
            if let FinalRotation = VidRotation
            {
                self.MetalView?.rotation = FinalRotation
            }
            self.DataOutputQueue.async
            {
                //enable rendering here
            }
        }
        #endif
    }
    
    /// Handle focus events.
    /// - Parameter with: The focus mode to use.
    /// - Parameter exposureMode: The exposure mode.
    /// - Parameter at: The device point to use for focusing/exposure control.
    /// - Parameter monitorSubjectAreaChange: If true, the area in `at` is watched for changes.
    func focus(with focusMode: AVCaptureDevice.FocusMode,
               exposureMode: AVCaptureDevice.ExposureMode,
               at devicePoint: CGPoint,
               monitorSubjectAreaChange: Bool)
    {
        #if targetEnvironment(simulator)
        Debug.Print("focus not supported on simulator")
        return
        #else
        SessionQueue.async
        {
            let VideoDevice = self.VideoDeviceInput.device
            do
            {
                try VideoDevice.lockForConfiguration()
                if VideoDevice.isFocusPointOfInterestSupported && VideoDevice.isFocusModeSupported(focusMode)
                {
                    VideoDevice.focusPointOfInterest = devicePoint
                    VideoDevice.focusMode = focusMode
                }
                
                if VideoDevice.isExposurePointOfInterestSupported && VideoDevice.isExposureModeSupported(exposureMode)
                {
                    VideoDevice.exposurePointOfInterest = devicePoint
                    VideoDevice.exposureMode = exposureMode
                }
                
                VideoDevice.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                VideoDevice.unlockForConfiguration()
            }
            catch
            {
                print("Error locking device for focus configuration: \(error.localizedDescription)")
            }
        }
        #endif
    }
    
    /// Take a picture and save it.
    /// - Note:
    ///   - The image is taken from the live stream and the current filter is used to process it.
    ///   - No action is taken if running on a simulator.
    func TakePicture()
    {
        #if targetEnvironment(simulator)
        print("Cannot take picture on simulator.")
        return
        #else
        SessionQueue.async
        {
            let Settings = AVCapturePhotoSettings(format: [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)])
            self.PhotoOutput.capturePhoto(with: Settings, delegate: self)
        }
        #endif
    }
    
    /// Called every time there is a new camera image to process during live view rendering.
    /// - Parameter output: Not used.
    /// - Parameter didOutput: Image buffer data.
    /// - connection: Not used.
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection)
    {
        ProcessLiveViewFrame(Buffer: sampleBuffer)
    }
    
    /// Process the buffer from the live view frame capture.
    /// - Note: If the video frame buffer filter returns nil for any reason (most likely due to transition
    ///         synchronization) the view will not be updated for the given frame. If there is a major issue
    ///         with a filter, it will be seen as a frozen live view as the live view won't be updated until
    ///         a new (and working) filter is put into place.
    /// - Parameter Buffer: The buffer with the data from the live view frame.
    func ProcessLiveViewFrame(Buffer: CMSampleBuffer)
    {
        guard let VideoPixelBuffer = CMSampleBufferGetImageBuffer(Buffer) else
        {
            print("Error getting sample buffer in ProcessLiveViewFrame.")
            return
        }
        guard let FormatDescription = CMSampleBufferGetFormatDescription(Buffer) else
        {
            print("Error getting format description.")
            return
        }
        Filters.Initialize(From: FormatDescription, Caller: "ProcessLiveViewFrame")
        let FinalPixelBuffer = VideoPixelBuffer
        MetalView!.pixelBuffer = Filters.RunFilter(With: FinalPixelBuffer)
        PreviousFrame = VideoPixelBuffer
        OperationQueue.main.addOperation
        {
            self.MetalView?.setNeedsDisplay()
        }
    }
    
    /// Handle taps in the metal live view component.
    /// - Note: Taps are used for focus and exposure control.
    /// - Parameter Gesture: The recognized gesture.
    @objc func HandleMetalViewTap(Gesture: UITapGestureRecognizer)
    {
        if Gesture.state == .ended
        {
            let Location = Gesture.location(in: MetalView!)
            let TextureRect = CGRect(origin: Location, size: .zero)
            let DeviceRect = VideoDataOutput.metadataOutputRectConverted(fromOutputRect: TextureRect)
            focus(with: .autoFocus,
                  exposureMode: .autoExpose,
                  at: DeviceRect.origin,
                  monitorSubjectAreaChange: true)
        }
    }
}
