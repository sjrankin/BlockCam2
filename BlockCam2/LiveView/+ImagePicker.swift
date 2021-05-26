//
//  +ImagePicker.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/11/21.
//

import Foundation
import UIKit
import MobileCoreServices
import Photos

extension LiveViewController
{
    // MARK: - UIImagePickerControllerDelegate functions.
    
    func GetImageFromAlbum()
    {
        let ImagePicker = UIImagePickerController()
        ImagePicker.sourceType = .photoLibrary
        ImagePicker.mediaTypes = ["public.image", "public.movie"]
        ImagePicker.delegate = self
        self.present(ImagePicker, animated: true, completion: nil)
    }
    
    /// Image picker canceled by the user. We only care about this because if we didn't, the image picker would never
    /// disappear - we have to close it manually.
    /// - Parameter picker: Not used.
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion: nil)
    }
    
    /// Image picker finished picking a media object notice.
    /// - Note: We only care about still images and videos. Each is processed through a different code path but ultimate the same
    ///         code generates the resultant image/video.
    /// - Parameter picker: Not used.
    /// - Parameter didFinishPickingMediaWithInfo: Information about the selected image/media.
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        self.dismiss(animated: true, completion: nil)
        var Final = UIImage()
        let MediaType = info[UIImagePickerController.InfoKey.mediaType] as! CFString
        switch MediaType
        {
            case kUTTypeMovie:
                if let VideoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL
                {
                    ApplyFilterToVideo(VideoURL, ScratchName: "TemporaryVideo.mov")
                }
                
            case kUTTypeImage:
                if let SelectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
                {
                    if let Asset: PHAsset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset
                    {
                        let ID = PHImageManager.default().requestImageDataAndOrientation(for: Asset, options: PHImageRequestOptions())
                        {
                            (AssetData, UTI, Orientation, Info) in
                            guard var SelectedCI = CIImage(image: SelectedImage) else
                            {
                                Debug.FatalError("Error convering photo album to CIImage.")
                            }
                            let Ori2 = LiveViewController.Orientations[Int(Orientation.rawValue)]!
                            switch Ori2
                            {
                                case "Up":
                                    Final = SelectedImage
                                    
                                case "UpMirrored":
                                    SelectedCI = SelectedCI.MirrorUp()
                                    Final = SelectedCI.AsUIImage()!
                                    
                                case "Down":
                                    SelectedCI = SelectedCI.Rotate180()
                                    Final = SelectedCI.AsUIImage()!
                                    
                                case "DownMirrored":
                                    SelectedCI = SelectedCI.MirrorDown()
                                    Final = SelectedCI.AsUIImage()!
                                    
                                case "LeftMirrored":
                                    SelectedCI = SelectedCI.RotateRight(AndMirror: true)
                                    Final = SelectedCI.AsUIImage()!
                                    
                                case "Right":
                                    SelectedCI = SelectedCI.RotateRight()
                                    Final = SelectedCI.AsUIImage()!
                                    
                                case "RightMirrored":
                                    SelectedCI = SelectedCI.RotateLeft(AndMirror: true)
                                    Final = SelectedCI.AsUIImage()!
                                    
                                case "Left":
                                    SelectedCI = SelectedCI.RotateRight()
                                    Final = SelectedCI.AsUIImage()!
                                    
                                default:
                                    Final = SelectedImage
                            }
                            
                            self.ImageFromAlbum(Final)
                        }
                    }
                }
                
            default:
                Debug.FatalError("Unexpected media type encountered: \(MediaType)")
        }
    }
    
    static var Orientations: [Int: String] =
    [
        1: "Up",
        2: "UpMirrored",
        3: "Down",
        4: "DownMirrored",
        5: "LeftMirrored",
        6: "Right",
        7: "RightMirrored",
        8: "Left"
    ]
}
