//
//  LiveViewControllerUI.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/15/21.
//

import Foundation
import UIKit
import SwiftUI

enum ChangedDataTypes
{
    case None
    case Button
    case Setting
}

/// Wrapper for the live view UI (which requires components not yet available in SwiftUI).
struct LiveViewControllerUI: UIViewControllerRepresentable
{
    @Binding var FilterButtonPressed: String
    @Binding var IsSelfieCamera: Bool
    @Binding var ShowFilterSettings: Bool
    @Binding var ToggleSavedImageNotice: Bool
    
    /// Returns the LiveViewController instance.
    func makeUIViewController(context: Context) -> LiveViewController
    {
        let ActualController = LiveViewController()
        ActualController.UIDelegate = context.coordinator //as! ViewControllerDelegate
        return ActualController
    }
    
    /// Handles data from the UI to the live view.
    func updateUIViewController(_ uiViewController: LiveViewController, context: Context)
    {
        uiViewController.ButtonPressed(FilterButtonPressed)
    }
   
    func makeCoordinator() -> Coordinator
    {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, ViewControllerDelegate//UIPageViewControllerDelegate
    {
        var Parent: LiveViewControllerUI
        
        init(_ Parent: LiveViewControllerUI)
        {
            self.Parent = Parent
        }
        
        func ShowFilterSettings(For: String)
        {
            print("ShowFilterSettings<-\(For)")
            Parent.ShowFilterSettings = true
        }
        
        func ToggleImageSavedNotice()
        {
            Parent.ToggleSavedImageNotice = true
        }
    }
}

protocol ViewControllerDelegate: AnyObject
{
    func ShowFilterSettings(For: String)
    func ToggleImageSavedNotice()
}
