//
//  UserSampleMainController.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/23/21.
//

import Foundation
import UIKit

class UserSampleMainController: UITableViewController, UserSampleParentProtocol
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        UpdateToolBar()
    }
    
    func UpdateToolBar()
    {
        self.navigationController?.isToolbarHidden = false
        var Buttons = self.navigationController?.toolbarItems
        Buttons?.insert(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), at: 2)
        Buttons?.insert(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), at: 4)
        self.toolbarItems = Buttons
    }
    
    var UserData: [SampleImageData] = SampleImages.UserDefinedSamples
    
    // MARK: - Table handling
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return UserData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if let Cell = tableView.dequeueReusableCell(withIdentifier: "UserImageCell") as? UserImageTableCell
        {
            Cell.UserImageThumbnail.image = UserData[indexPath.row].SampleImage
            Cell.UserImageTitle.text = UserData[indexPath.row].Title
            Cell.tag = indexPath.row
            
            return Cell
        }
        return UITableViewCell()
    }
    
    // MARK: Button handlers
    
    @IBAction func RecycleButtonHandler(_ sender: Any)
    {
        self.tableView.reloadData()
    }
    
    @IBAction func TrashButtonHandler(_ sender: Any)
    {
        let Alert = UIAlertController(title: "Really Delete?",
                                      message: "Do you really want to delete the selected image from BlockCam?",
                                      preferredStyle: .alert)
        Alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        Alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler:
                                        {
                                            Action in
                                            if let Indices = self.tableView.indexPathsForSelectedRows
                                            {
                                                if !Indices.isEmpty
                                                {
                                                    let Index = Indices.first!.row
                                                    self.UserData.remove(at: Index)
                                                    DispatchQueue.main.async
                                                    {
                                                        self.tableView.reloadData()
                                                    }
                                                }
                                            }
                                        }))
    }
    
    @IBAction func TrashAllButtonHandler(_ sender: Any)
    {
    }
    
    @IBAction func EditButtonHandler(_ sender: Any)
    {
        
    }
    
    @IBAction func AddButtonHandler(_ sender: Any)
    {
        
    }
    
    @IBSegueAction func EditInstantiation(_ coder: NSCoder) -> UserSampleEditorController?
    {
        let Controller = UserSampleEditorController(coder: coder)
        if let Index = self.tableView.indexPathForSelectedRow
        {
            (Controller)?.SetImageIndex(Index.row)
            (Controller)?.Parent = self
            return Controller
        }
        return nil
    }
    
    @IBSegueAction func AddInstantiation(_ coder: NSCoder) -> UserSampleAddController?
    {
        let Controller = UserSampleAddController(coder: coder)
        if let Index = self.tableView.indexPathForSelectedRow
        {
            (Controller)?.SetImageIndex(Index.row)
            (Controller)?.Parent = self
            return Controller
        }
        return nil
    }
    
    // MARK: - Protocol handling.
    
    func Deleted(At Index: Int)
    {
        
    }
    
    func Added()
    {
        
    }
    
    func Edited(At Index: Int)
    {
        
    }
    
    // MARK: Interface builder outlets
    
    @IBOutlet weak var AddButton: UIBarButtonItem!
    @IBOutlet weak var EditButton: UIBarButtonItem!
    @IBOutlet weak var RecycleButton: UIBarButtonItem!
    @IBOutlet weak var TrashButton: UIBarButtonItem!
    @IBOutlet weak var TrashAllButton: UIBarButtonItem!
}
