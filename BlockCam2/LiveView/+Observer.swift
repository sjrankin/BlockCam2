//
//  +Observer.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/18/21.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
import Photos

extension LiveViewController
{
    // MARK: - Notificaton setup and teardown.
    
    /// Add notification center observers.
    func AddObservers()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(DidEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SessionRuntimeError),
                                               name: NSNotification.Name.AVCaptureSessionRuntimeError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ThermalStateChanged),
                                               name: ProcessInfo.thermalStateDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SessionWasInterrupted),
                                               name: NSNotification.Name.AVCaptureSessionWasInterrupted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SessionInterruptionEnded),
                                               name: NSNotification.Name.AVCaptureSessionInterruptionEnded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SubjectAreaChanged),
                                               name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange, object: nil)
    }
    
    /// Remove notification center observers.
    func RemoveObservers()
    {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Notification event handlers.
    
    /// App entered the background handling.
    @objc func DidEnterBackground(notification: NSNotification)
    {
        DataOutputQueue.async
        {
            self.CurrentDepthPixelBuffer = nil
            self.VideoDepthConverter.reset()
            self.MetalView!.pixelBuffer = nil
            self.MetalView!.FlushTextureCache()
        }
        ProcessingQueue.async
        {
            self.PhotoDepthMixer.reset()
            self.PhotoDepthConverter.reset()
        }
    }
    
    /// App will enter the foreground handling.
    @objc func WillEnterForeground(notification: NSNotification)
    {
        DataOutputQueue.async
        {
        }
    }
    
    /// Session runtime error.
    @objc func SessionRuntimeError(notification: NSNotification)
    {
        guard let ErrorValue = notification.userInfo?[AVCaptureSessionErrorKey] as? NSError else
        {
            //Error getting the error - for now, just give up and return.
            return
        }
        let TheError = AVError(_nsError: ErrorValue)
        print("Session runtime error: \(TheError.localizedDescription)")
        if TheError.code == .mediaServicesWereReset
        {
            self.SessionQueue.async
            {
                    self.CaptureSession.startRunning()
            }
        }
    }
    
    /// Session was interrupted handling.
    @objc func SessionWasInterrupted(notification: NSNotification)
    {
        if let UserInfoValue = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?,
           let ReasonIntValue = UserInfoValue.integerValue,
           let Reason = AVCaptureSession.InterruptionReason(rawValue: ReasonIntValue)
        {
            switch Reason
            {
                case .videoDeviceInUseByAnotherClient:
                    print("Session interruped because video device not available due to being used by other client.")
                    
                case .videoDeviceNotAvailableWithMultipleForegroundApps:
                    print("Session interruped because video device not available with multiple foreground apps.")
                    
                case .videoDeviceNotAvailableInBackground:
                    print("Session interruped because video device not available when app in the background.")
                    
                case .videoDeviceNotAvailableDueToSystemPressure:
                    print("Session interruped because video device not available due to system pressure.")
                    
                case .audioDeviceInUseByAnotherClient:
                    print("Session interruped because audio in use by other client.")
                    
                @unknown default:
                    fatalError("Unknown reason in \(#function)")
            }
        }
    }
    
    /// Session was restored handling.
    @objc func SessionInterruptionEnded(notification: NSNotification)
    {
        //For whatever reason why the session was interrupted, it's gone now so we can restore the UI if needed.
    }
    
    /// Subject area in the live view changed handling.
    @objc func SubjectAreaChanged(notification: NSNotification)
    {
        let DevicePoint = CGPoint(x: 0.5, y: 0.5)
        focus(with: .continuousAutoFocus, exposureMode: .continuousAutoExposure, at: DevicePoint, monitorSubjectAreaChange: false)
    }
    
    /// Device orientation change handling.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        #if targetEnvironment(simulator)
        #else
        coordinator.animate(
            alongsideTransition:
                {
                    _ in
                    let InterfaceOrientation = self.CurrentOrientation()
                    self.StatusBarOrientation = InterfaceOrientation
                    self.SessionQueue.async
                    {
                        if let PhotoOrientation = AVCaptureVideoOrientation(rawValue: InterfaceOrientation.rawValue)
                        {
                            self.PhotoOutput.connection(with: .video)!.videoOrientation = PhotoOrientation
                        }
                        let VideoOrientation = self.VideoDataOutput.connection(with: .video)!.videoOrientation
                        if let VRotation = LiveMetalView.ViewRotations(with: InterfaceOrientation, videoOrientation: VideoOrientation,
                                                                  cameraPosition: self.VideoDeviceInput.device.position)
                        {
                            self.MetalView?.rotation = VRotation
                        }
                    }
                    DispatchQueue.main.async
                    {
                        //update filters as needed
                    }
                }
            , completion: nil)
        #endif
    }
    
    /// Thermal state change handling.
    @objc func ThermalStateChanged(notification: NSNotification)
    {
        if let PInfo = notification.object as? ProcessInfo
        {
            DispatchQueue.main.async
            {
                self.ThermalStateUserNotification(PInfo.thermalState)
            }
        }
    }
    
    /// If necessary, notify the user of thermal state changes.
    func ThermalStateUserNotification(_ State: ProcessInfo.ThermalState)
    {
        var ShowAlert = false
        var ThermalMessage = ""
        switch State
        {
            case .nominal:
                ThermalMessage = "Thermal state is nominal."
                
            case .fair:
                ThermalMessage = "Thermal state is fair."
                
            case .serious:
                ShowAlert = true
                ThermalMessage = "Thermal state is serious."
                
            case .critical:
                ShowAlert = true
                ThermalMessage = "Thermal state is critical."
                
            @unknown default:
                fatalError("Unknown thermal state encountered: \(State)")
        }
        print(ThermalMessage)
        if ShowAlert
        {
            let Alert = UIAlertController(title: "BlockCam Thermal Alert", message: ThermalMessage, preferredStyle: .alert)
            Alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(Alert, animated: true)
        }
    }
}
