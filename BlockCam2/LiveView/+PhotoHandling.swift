//
//  +PhotoHandling.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/20/21.
//

import Foundation
import UIKit
import CoreImage
import CoreVideo
import AVFoundation
import Photos
import MobileCoreServices
import CoreServices

/// Code for handling photos.
extension LiveViewController
{
    /// didFinishProcessingPhoto delegate handler.
    /// - Parameters:
    ///   - output: The output of the photo capture process.
    ///   - photo: Contains photo information.
    ///   - error: If not nil, error information.
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?)
    {
        let Start = CACurrentMediaTime()
        guard let PhotoPixelBuffer = photo.pixelBuffer else
        {
            ShowSaveError(With: "Internal error: \((error?.localizedDescription)!)")
            print("Error capturing photo buffer - no pixel buffer: \((error?.localizedDescription)!)")
            return
        }
        var PhotoFormat: CMFormatDescription?
        CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault,
                                                     imageBuffer: PhotoPixelBuffer,
                                                     formatDescriptionOut: &PhotoFormat)
        
        var ImageToSave: UIImage = UIImage()
        ProcessingQueue.async
        {
            Filters.Initialize(From: PhotoFormat!, Caller: "photoOutput")
            if let ImageBuffer = Filters.RunFilter(With: PhotoPixelBuffer)
            {
                let CImg = CIImage(cvImageBuffer: ImageBuffer)
                let Context = CIContext(options: nil)
                let CGImg = Context.createCGImage(CImg, from: CImg.extent)!
                ImageToSave = UIImage(cgImage: CGImg).RotateImage(By: 90.0 * Double.pi / 180.0)
            }
            
            PHPhotoLibrary.requestAuthorization
            {
                Status in
                if Status == .authorized
                {
                    PHPhotoLibrary.shared().performChanges(
                        {
                            let CreationRequest = PHAssetCreationRequest.forAsset()
                            let ImageData = ImageToSave.jpegData(compressionQuality: 1.0)!
                            CreationRequest.addResource(with: .photo, data: ImageData, options: nil)
                            let SaveDuration = CACurrentMediaTime() - Start
                            if SaveDuration < 2.0
                            {
                                self.UIDelegate?.HideShortMessage(With: 2.0 - SaveDuration)
                            }
                            else
                            {
                                self.UIDelegate?.HideShortMessage()
                            }
                        },
                        completionHandler:
                            {
                                _, error in
                                if let error = error
                                {
                                    self.ShowSaveError(With: "Image save error: \(error.localizedDescription)")
//                                    fatalError("Error saving photo to library: \(error.localizedDescription)")
                                }
                            }
                    )
                }
                else
                {
                    self.ShowSaveError(With: "BlockCam is not authorized to save images to the camera roll.")
//                    fatalError("Not authorized to save pictures")
                }
            }
        }
        
        var WhatSaved = "Image"
        #if false
        if _Settings.bool(forKey: "SaveOriginalImage")
        {
            
            //let MetaData: CFDictionary = photo.metadata as CFDictionary
            let MetaData = photo.metadata
            if SaveImageAsJPeg(PixelBuffer: PhotoPixelBuffer, MetaData: MetaData)
            {
                WhatSaved = "Images"
            }
        }
        #endif
    }
    
    /// Show a simple (non-SwiftUI) alert intended to display photo save error messages.
    /// - Note: Currently, the title is set to "Error Saving Image".
    /// - Parameter With: The message to display.
    func ShowSaveError(With Message: String)
    {
        UIDelegate?.HideShortMessage()
        let Alert = UIAlertController(title: "Error Saving Image",
                                      message: Message,
                                      preferredStyle: .alert)
        self.present(Alert, animated: true)
    }
    
    /// Determines if the passed UTI is supported on the running system.
    /// - Note: See [Formal way to verify UTIs](https://stackoverflow.com/questions/45905880/whats-the-formal-way-to-verify-if-my-device-is-capable-of-encoding-images-in-he)
    /// - Parameter PhotoType: UTI to verify against a list of system-supported UTIs. Case sensitive. Check
    ///                        with Apple documentation for actual strings.
    /// - Returns: True if the passed UTI is in the supported listed, false if not.
    func SystemSupports(PhotoType: String) -> Bool
    {
        let SupportedTypes = CGImageDestinationCopyTypeIdentifiers() as NSArray
        return SupportedTypes.contains(PhotoType)
    }
    
    #if false
    @objc func HandleTapForFocus(Location: CGPoint)
    {
        guard let TexturePoint = MetalView?.texturePointForView(point: Location) else
        {
            return
        }
        let TextureRect = CGRect(origin: TexturePoint, size: .zero)
        let DeviceRect = VideoDataOutput.metadataOutputRectConverted(fromOutputRect: TextureRect)
        focus(with: .autoFocus, exposureMode: .autoExpose, at: DeviceRect.origin, monitorSubjectAreaChange: true)
    }
    #endif
}


