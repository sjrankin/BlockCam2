//
//  LiveViewController.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/18/21.
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

/// View controller to display the live view from the camera as well as 3D results if required.
class LiveViewController: UIViewController,
                          AVCapturePhotoCaptureDelegate,
                          AVCaptureVideoDataOutputSampleBufferDelegate,
                          AVCaptureDepthDataOutputDelegate,
                          AVCaptureDataOutputSynchronizerDelegate,
                          AudioProtocol,
                          SettingChangedProtocol
{
    /// Delegate to the SwiftUI coordinator for the user interface.
    weak var UIDelegate: ViewControllerDelegate? = nil
    
    /// Initialize the view controller.
    override func viewDidLoad()
    {
        super.viewDidLoad()
        Settings.Initialize()
        Settings.AddSubscriber(self)
        InitializeFileStructure()
        Filters.InitializeFilters()
        Filters.InitializeFilterTree()
        FilterData.Initialize()
        definesPresentationContext = true
        MetalView = LiveMetalView()
        MetalView?.Initialize(self.view.frame)
        self.view.addSubview(MetalView!)
        let Tap = UITapGestureRecognizer(target: self, action: #selector(HandleMetalViewTap))
        Tap.numberOfTapsRequired = 1
        MetalView?.addGestureRecognizer(Tap)
        
        GetPermissions()
        #if !targetEnvironment(simulator)
        InitializeAudio()
        InitializeCamera()
        #endif
    }
    
    /// Initialize the file structure.
    /// - Note: Two directories are required:
    ///     1. A scratch directory for image processing.
    ///     2. A sample directory for on-boarding.
    func InitializeFileStructure()
    {
        if !FileIO.CreateIfDoesNotExist(DirectoryName: FileIO.ScratchDirectory)
        {
            fatalError("Error creating \(FileIO.ScratchDirectory)")
        }
        if !FileIO.CreateIfDoesNotExist(DirectoryName: FileIO.SampleDirectory)
        {
            fatalError("Error creating \(FileIO.SampleDirectory)")
        }
    }
    
    /// Override the will appear event. Handles late intialization.
    /// - Parameter animated: Passed to super class.
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        let Orientation = CurrentOrientation()
        StatusBarOrientation = Orientation
        InitializeCapture()
    }
    
    /// Not currently used.
    func UpdatePreviewLayer(Layer: AVCaptureConnection, Orientation: AVCaptureVideoOrientation)
    {
        Layer.videoOrientation = Orientation
        VideoPreviewLayer!.frame = MetalView!.bounds
    }
    
    /// Not currently used.
    func dataOutputSynchronizer(_ synchronizer: AVCaptureDataOutputSynchronizer,
                                didOutput synchronizedDataCollection: AVCaptureSynchronizedDataCollection)
    {
        if let SyncedVideoData: AVCaptureSynchronizedSampleBufferData = synchronizedDataCollection.synchronizedData(for: VideoDataOutput) as? AVCaptureSynchronizedSampleBufferData
        {
            if !SyncedVideoData.sampleBufferWasDropped
            {
                let VidSampleBuf = SyncedVideoData.sampleBuffer
                ProcessLiveViewFrame(Buffer: VidSampleBuf)
            }
        }
    }

    // MARK: - UI actions
    
    
    
    var PreviousButtonCommand: String = ""
    
    /// Handle button presses from the user interface.
    /// - Parameter Name: The name of the button.
    public func ButtonPressed(_ Name: String)
    {
        if !Name.isEmpty
        {
            let Parts = Name.split(separator: ".", omittingEmptySubsequences: true)
            let FirstName = String(Parts[0])
            var SecondName = ""
            if Parts.count > 1
            {
                SecondName = String(Parts[1])
            }
            switch FirstName
            {
                case "Camera":
                    TakePicture() 
                    
                case "Album":
                    break
                    
                case "Selfie":
                    DoSwitchCameras()
                    
                case "Filters":
                    if SecondName == Name
                    {
                        return
                    }
                    PreviousButtonCommand = SecondName
                    if let Filter = BuiltInFilters(rawValue: SecondName)
                    {
                        Settings.SetString(.CurrentFilter, SecondName)
                        Filters.SetFilter(Filter)
                    }
                    else
                    {
                        Settings.SetString(.CurrentFilter, "Passthrough")
                        Filters.SetFilter(.Passthrough)
                    }
                    
                case "Settings":
                    break
                    
                default:
                    break
            }
        }
    }
    
    func GetBuiltInFilterList() -> [String]
    {
        return Filters.AlphabetizedFilterNames()
    }
    
    // MARK: - Settings handling.
    
    func SubscriberID() -> UUID
    {
        return UUID()
    }
    
    func SettingChanged(Setting: SettingKeys, OldValue: Any?, NewValue: Any?)
    {
        switch Setting
        {
            case .SaveOriginalImage:
                if let NewBool = NewValue as? Bool
                {
                Debug.Print("\(Setting.rawValue)<-\(NewBool)")
                }
                
            case .ShowAudioWaveform:
                if let NewBool = NewValue as? Bool
                {
                Debug.Print("\(Setting.rawValue)<-\(NewBool)")
                }
                
            default:
                break
        }
    }
    
    //MARK: - Class-global variables.
    
    let VideoDataOutput = AVCaptureVideoDataOutput()
    let PhotoOutput = AVCapturePhotoOutput()
    let VideoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera,
                                                                                     .builtInWideAngleCamera],
                                                                       mediaType: .video,
                                                                       position: .unspecified)
    let SessionQueue = DispatchQueue(label: "SessionQueue", attributes: [], autoreleaseFrequency: .workItem)
    let ProcessingQueue = DispatchQueue(label: "PhotoProcessingQueue", attributes: [], autoreleaseFrequency: .workItem)
    let DataOutputQueue = DispatchQueue(label: "VideoDataQueue", qos: .userInitiated, attributes: [],
                                        autoreleaseFrequency: .workItem)
    var VideoOutput = AVCaptureVideoDataOutput()
    var CaptureSession: AVCaptureSession = AVCaptureSession()
    var VideoPreviewLayer: AVCaptureVideoPreviewLayer? = nil
    var CapturePhotoOutput: AVCapturePhotoOutput?
    var OutputSynchronizer: AVCaptureDataOutputSynchronizer? = nil
    var DepthDataOutput = AVCaptureDepthDataOutput()
    var CurrentDepthPixelBuffer: CVPixelBuffer? = nil
    let VideoDepthConverter = DepthToGrayscaleConverter()
    let PhotoDepthConverter = DepthToGrayscaleConverter()
    let PhotoDepthMixer = VideoMixer()
    let VideoDepthMixer = VideoMixer()
    var FinalPixelBuffer: CVPixelBuffer!
    var callcount = 0
    var HistogramLayer = CAShapeLayer()
    var HistogramInitialized = false
    var ConfiguredOK: Bool = false
    var ConfigResults: Result<Bool, SetupResults>? = nil
    var StatusBarOrientation: UIInterfaceOrientation = .portrait
    var VideoDeviceInput: AVCaptureDeviceInput!
    var SetupResult: SetupResults = .Success
    var CaptureSessionContext = 0
    var Microphone: AudioProcessor? = nil
    var CameraHasDepth = false
    var DeviceHasCamera = true
    var MetalView: LiveMetalView? = nil
    static let RollingMeanWindowSize = 10
    static let AccumulationCount = 10
    static let MicrophoneBinCount = 256
    var HaveCapturePermission = true
    var HavePhotoLibraryAccess = true
    var Frames = Stack<CVPixelBuffer>()
    var PreviousFrame: CVPixelBuffer? = nil
}

/// Hardware setup and intialization results.
public enum SetupResults: String, CaseIterable, Error
{
    /// Setup was successful.
    case Success = "Success"
    /// General initial setup failure.
    case SetupFailure = "Initial setup failure."
    /// Running on a simulator with no simulated required hardware.
    case OnSimulator = "Running on simulator."
    /// Did not find a video device.
    case NoVideoDevice = "No video device."
    /// Error creating the input video device.
    case CannotCreateInputDevice = "Error creating input video device."
    /// Error adding the input video device to the capture session.
    case CannotAddVideoDevice = "Cannot add video device input to capture session."
    /// Error adding the output video device to the capture session.
    case CannotAddVideoOutput = "Cannot add video device output to capture session."
    /// Error adding the photo device to the capture session.
    case CannotAddPhotoDevice = "Cannot add photo device to capture session."
}
