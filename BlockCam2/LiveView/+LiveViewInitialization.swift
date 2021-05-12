//
//  +LiveViewInitialization.swift
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
    // MARK: - Initialize the camera.
    
    /// Initialize the camera. Ensures the user has granted authorization.
    func InitializeCamera()
    {
        CaptureDeviceIsAuthorized()
        ConfigureCamera()
    }
    
    /// Determines if the user has authorized the app to access the camera.
    func CaptureDeviceIsAuthorized()
    {
        switch AVCaptureDevice.authorizationStatus(for: .video)
        {
            case .authorized:
                break
                
            case .notDetermined:
                SessionQueue.suspend()
                AVCaptureDevice.requestAccess(for: .video)
                {
                    Granted in
                    if !Granted
                    {
                        fatalError("Capture device request failed")
                    }
                    self.SessionQueue.resume()
                }
                
            default:
                fatalError("Not authorized to capture video")
        }
    }
    
    /// Call the camera configuration routines to initialize the camera.
    func ConfigureCamera()
    {
        SessionQueue.async
        {
            let ConfigResults = self.ConfigureLiveView()
            switch ConfigResults
            {
                case .success(let OkeyDokey):
                    print("Configuration succeeded")
                    self.ConfiguredOK = OkeyDokey
                    
                case .failure(let Why):
                    print("Configuration failed: \(Why.rawValue)")
            }
        }
    }
    
    /// Configure live view.
    /// - Returns: Result code with `SetupResults` describing any errors that may have occurred. If
    ///            the code is running on a simulator, an error is returned.
    @discardableResult func ConfigureLiveView() -> Result<Bool, SetupResults>
    {
        #if targetEnvironment(simulator)
        return .failure(.OnSimulator)
        #endif
        if SetupResult != .Success
        {
            return .failure(.SetupFailure)
        }
        let DefaulVideoDevice: AVCaptureDevice? = VideoDeviceDiscoverySession.devices.first
        guard let DefVideoDevice = DefaulVideoDevice else
        {
            return .failure(.NoVideoDevice)
        }
        do
        {
            VideoDeviceInput = try AVCaptureDeviceInput(device: DefVideoDevice)
        }
        catch
        {
            return .failure(.CannotCreateInputDevice)
        }
        
        CaptureSession.beginConfiguration()
        
        CaptureSession.sessionPreset = AVCaptureSession.Preset.photo
        guard CaptureSession.canAddInput(VideoDeviceInput) else
        {
            CaptureSession.commitConfiguration()
            return .failure(.CannotCreateInputDevice)
        }
        CaptureSession.addInput(VideoDeviceInput)
        
        guard CaptureSession.canAddOutput(VideoDataOutput) else
        {
            CaptureSession.commitConfiguration()
            return .failure(.CannotAddVideoOutput)
        }
        CaptureSession.addOutput(VideoDataOutput)
        VideoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        VideoDataOutput.setSampleBufferDelegate(self, queue: DataOutputQueue)
        
        guard CaptureSession.canAddOutput(PhotoOutput) else
        {
            CaptureSession.commitConfiguration()
            return .failure(.CannotAddPhotoDevice)
        }
        CaptureSession.addOutput(PhotoOutput)
        PhotoOutput.isHighResolutionCaptureEnabled = true
        
        CaptureSession.commitConfiguration()
        return .success(true)
    }
    
    /// Prepare for running live view.
    func PrepareForLiveView()
    {
        StatusBarOrientation = CurrentOrientation()
    }
    
    /// Returns the current interface orientation.
    /// - Note: On iOS 13 and greater, the newer method of determination is used. Earlier iOS versions
    ///         use the deprecated method.
    func CurrentOrientation() -> UIInterfaceOrientation
    {
        if #available(iOS 13.0, *)
        {
            return UIApplication.shared.windows.first?.windowScene?.interfaceOrientation ?? .portrait
        }
        else
        {
            return UIApplication.shared.statusBarOrientation
        }
    }
    
    /// Initialize image capturing.
    func InitializeCapture()
    {
        #if targetEnvironment(simulator)
        return
        #else
        SessionQueue.async
        {
            if self.ConfiguredOK
            {
                self.AddObservers()
                if let AVOrientation = AVCaptureVideoOrientation(rawValue: self.StatusBarOrientation.rawValue)
                {
                    self.PhotoOutput.connection(with: .video)!.videoOrientation = AVOrientation
                }
                let VideoOrientation = self.VideoDataOutput.connection(with: .video)!.videoOrientation
                let VideoDevicePosition = self.VideoDeviceInput.device.position
                let ViewRotation = LiveMetalView.ViewRotations(with: self.StatusBarOrientation,
                                                               videoOrientation: VideoOrientation,
                                                               cameraPosition: VideoDevicePosition)
                self.MetalView?.Mirroring = (VideoDevicePosition == .front)
                if let Rotation = ViewRotation
                {
                    self.MetalView?.rotation = Rotation
                }
                self.DataOutputQueue.async
                {
                    //enable rendering here
                }
                self.CaptureSession.startRunning()
            }
            else
            {
                let Message = "Error configuring Block Cam 2"
                print(Message)
                let Alert = UIAlertController(title: "BlockCam 2", message: Message, preferredStyle: .alert)
                Alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(Alert, animated: true, completion: nil)
            }
        }
        #endif
    }
    
    /// Ask for the necessary permissions from the user.
    /// - Note:
    ///   - There are two sets of permissions required to use BlockCam:
    ///        - Camera access.
    ///        - Photo roll access.
    func GetPermissions()
    {
        HaveCapturePermission = false
        switch AVCaptureDevice.authorizationStatus(for: .video)
        {
            case .authorized:
                self.HaveCapturePermission = true
                
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video, completionHandler:
                                                {
                                                    granted in
                                                    if granted
                                                    {
                                                        self.HaveCapturePermission = true
                                                    }
                                                })
                
            case .denied:
                break
                
            case .restricted:
                return
                
            @unknown default:
                print("Unexpected camera authorization status in \(#file)")
        }
        
        HavePhotoLibraryAccess = false
        switch PHPhotoLibrary.authorizationStatus()
        {
            case .authorized:
                HavePhotoLibraryAccess = true
                
            case .denied:
                //User denied access.
                break
                
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization
                {
                    Status in
                    switch Status
                    {
                        case .authorized:
                            self.HavePhotoLibraryAccess = true
                            
                        case .denied:
                            break
                            
                        case .restricted:
                            break
                            
                        case .notDetermined:
                            break
                            
                        case .limited:
                            self.HaveCapturePermission = true
                            
                        @unknown default:
                            break
                    }
                }
                
            case .restricted:
                //Cannot access and the user cannot grant access.
                break
                
            case .limited:
                HavePhotoLibraryAccess = true
                
            @unknown default:
                fatalError("Unknown photo library authorization status in \(#file)")
        }
    }
}
