//
//  UserSampleEditorController.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/23/21.
//

import Foundation
import UIKit

class UserSampleEditorController: UIViewController, UITextFieldDelegate, UserSampleProtocol
{
    var Parent: UserSampleParentProtocol? = nil
    
    func SetImageIndex(_ Index: Int)
    {
        ImageIndex = Index
        let UserData = SampleImages.UserDefinedSamples[Index]
        UserSampleDescription.text = UserData.Title
        UserImageSample.image = UserData.SampleImage
    }
    
    var ImageIndex: Int? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        UpdateToolBar()
    }
    
    func UpdateToolBar()
    {
        self.navigationController?.isToolbarHidden = false
        var Buttons = self.navigationController?.toolbarItems
        Buttons?.insert(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), at: 1)
        Buttons?.insert(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), at: 3)
        self.toolbarItems = Buttons
    }
    
    @IBAction func CancelButtonHandler(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func DeleteButtonHandler(_ sender: Any)
    {
        if let CurrentIndex = ImageIndex
        {
            let Alert = UIAlertController(title: "Really Delete?",
                                          message: "Do you really want to delete the this image from BlockCam?",
                                          preferredStyle: .alert)
            Alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            Alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler:
                                            {
                                                Action in
                                                self.Parent?.Deleted(At: CurrentIndex)
                                                self.navigationController?.popViewController(animated: true)
                                                self.dismiss(animated: true, completion: nil)
                                            }
            ))
        }
    }
    
    @IBAction func OKButtonHandler(_ sender: Any)
    {
        if let Index = ImageIndex
        {
            let SampleName = SampleImages.UserDefinedSamples[Index].SampleName
            let Description = UserSampleDescription.text ?? "User Sample Image"
            SampleImages.EditUserSample(FileName: SampleName, Description: Description)
            self.Parent?.Edited(At: Index)
        }
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var OKButton: UIBarButtonItem!
    @IBOutlet weak var CancelEditButton: UIBarButtonItem!
    @IBOutlet weak var DeleteImageButton: UIBarButtonItem!
    @IBOutlet weak var UserImageSample: UIImageView!
    @IBOutlet weak var UserSampleDescription: UITextField!
}
