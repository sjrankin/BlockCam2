//
//  UserSampleAddController.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/23/21.
//

import Foundation
import UIKit
import AVFoundation
import CoreImage
import AVKit
import CoreServices
import MobileCoreServices
import Photos

class UserSampleAddController: UIViewController, UIImagePickerControllerDelegate,
                               UINavigationControllerDelegate, UserSampleProtocol
{
    var Parent: UserSampleParentProtocol? = nil
    
    func SetImageIndex(_ Index: Int)
    {
        ImageIndex = Index
    }
    
    var ImageIndex: Int? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        OKButton.isEnabled = false
    }
    
    @IBAction func OKButtonHandler(_ sender: Any)
    {
        Parent?.Edited(At: ImageIndex!)
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func CancelButtonHandler(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func PhotoAlbumButtonHandler(_ sender: Any)
    {
        let ImagePicker = UIImagePickerController()
        ImagePicker.sourceType = .photoLibrary
        ImagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: UIImagePickerController.SourceType.photoLibrary)!
        ImagePicker.delegate = self
        self.present(ImagePicker, animated: true)
        {
            print("ImagePicker completed")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        self.dismiss(animated: true, completion: nil)
        if info[UIImagePickerController.InfoKey.mediaType] as! CFString == kUTTypeImage
        {
            if let photo = info[.phAsset] as? PHAsset
            {
                if let Name = photo.value(forKey: "filename") as? String
                {
                    ImageName = Name
                }
            }
            if let SelectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            {
                ImageAdded = true
                self.SampleImageView.image = SelectedImage
            }
        }
    }
    
    var ImageName: String = ""
    var ImageAdded: Bool = false
    
    @IBOutlet weak var PlaceholderText: UILabel!
    @IBOutlet weak var PhotoAlbumButton: UIButton!
    @IBOutlet weak var ImageDescription: UITextField!
    @IBOutlet weak var SampleImageView: UIImageView!
    @IBOutlet weak var OKButton: UIBarButtonItem!
    @IBOutlet weak var CancelButton: UIBarButtonItem!
}
