//
//  LiveViewMetalExtensions.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/19/21.
//

import Foundation
import AVFoundation
import AVKit

extension LiveMetalView.ViewRotations 
{
    //MARK: - ViewRotations extensions.
    
    /// Initializer for the `ViewRotations` enum to calculate the proper rotation based on various
    /// parameters.
    /// - Parameter interfaceOrientation: The current user interface orientation.
    /// - Parameter videoOrientation: The current orientation of the video capture device.
    /// - Parameter cameraPosition: The position of the camera being used.
    init?(with interfaceOrientation: UIInterfaceOrientation, videoOrientation: AVCaptureVideoOrientation,
          cameraPosition: AVCaptureDevice.Position)
    {
        // Calculate the rotation between the videoOrientation and the interfaceOrientation.
        // The direction of the rotation depends upon the camera position.
        switch videoOrientation
        {
            case .portrait:
                switch interfaceOrientation
                {
                    case .landscapeRight:
                        if cameraPosition == .front
                        {
                            self = .rotate90Degrees
                        }
                        else
                        {
                            self = .rotate270Degrees
                        }
                        
                    case .landscapeLeft:
                        if cameraPosition == .front
                        {
                            self = .rotate270Degrees
                        }
                        else
                        {
                            self = .rotate90Degrees
                        }
                        
                    case .portrait:
                        self = .rotate0Degrees
                        
                    case .portraitUpsideDown:
                        self = .rotate180Degrees
                        
                    default: return nil
                }
                
            case .portraitUpsideDown:
                switch interfaceOrientation
                {
                    case .landscapeRight:
                        if cameraPosition == .front
                        {
                            self = .rotate270Degrees
                        }
                        else
                        {
                            self = .rotate90Degrees
                        }
                        
                    case .landscapeLeft:
                        if cameraPosition == .front
                        {
                            self = .rotate90Degrees
                        }
                        else
                        {
                            self = .rotate270Degrees
                        }
                        
                    case .portrait:
                        self = .rotate180Degrees
                        
                    case .portraitUpsideDown:
                        self = .rotate0Degrees
                        
                    default: return nil
                }
                
            case .landscapeRight:
                switch interfaceOrientation
                {
                    case .landscapeRight:
                        self = .rotate0Degrees
                        
                    case .landscapeLeft:
                        self = .rotate180Degrees
                        
                    case .portrait:
                        if cameraPosition == .front
                        {
                            self = .rotate270Degrees
                        }
                        else
                        {
                            self = .rotate90Degrees
                        }
                        
                    case .portraitUpsideDown:
                        if cameraPosition == .front
                        {
                            self = .rotate90Degrees
                        }
                        else
                        {
                            self = .rotate270Degrees
                        }
                        
                    default: return nil
                }
                
            case .landscapeLeft:
                switch interfaceOrientation
                {
                    case .landscapeLeft:
                        self = .rotate0Degrees
                        
                    case .landscapeRight:
                        self = .rotate180Degrees
                        
                    case .portrait:
                        if cameraPosition == .front
                        {
                            self = .rotate90Degrees
                        }
                        else
                        {
                            self = .rotate270Degrees
                        }
                        
                    case .portraitUpsideDown:
                        if cameraPosition == .front
                        {
                            self = .rotate270Degrees
                        }
                        else
                        {
                            self = .rotate90Degrees
                        }
                        
                    default: return nil
                }
        }
    }
}
