//
//  ImagePicker.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/10/21.
//

import Foundation
import CoreImage
import UIKit
import Photos
import SwiftUI

//https://www.appcoda.com/swiftui-camera-photo-library/
struct ImagePicker: UIViewControllerRepresentable
{
    @Binding var SelectedImage: UIImage?
    @Binding var SelectedImageName: String?
    @Binding var SelectedImageURL: URL?
    @Environment(\.presentationMode) var PresentationMode
    var SourceType: UIImagePickerController.SourceType = .photoLibrary
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> some UIImagePickerController
    {
        let Picker = UIImagePickerController()
        Picker.delegate = context.coordinator
        Picker.allowsEditing = false
        Picker.sourceType = SourceType
        return Picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: UIViewControllerRepresentableContext<ImagePicker>)
    {
    }
    
    func makeCoordinator() -> Coordinator
    {
        Coordinator(self)
    }
}

final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var parent: ImagePicker
    
    init(_ parent: ImagePicker) {
        self.parent = parent
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            parent.SelectedImage = image
        }
        if let ImageURL = info[UIImagePickerController.InfoKey.imageURL] as? URL
        {
            parent.SelectedImageURL = ImageURL
        }
        else
        {
            parent.SelectedImageURL = nil
        }
        if let photo = info[.phAsset] as? PHAsset
        {
            if let Name = photo.value(forKey: "filename") as? String
            {
                parent.SelectedImageName = Name
            }
            else
            {
                parent.SelectedImageName = nil
            }
        }
        parent.PresentationMode.wrappedValue.dismiss()
    }
}
