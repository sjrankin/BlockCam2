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
        ActualController.UIDelegate = context.coordinator
        return ActualController
    }
    
    /// Handles data from the UI to the live view.
    func updateUIViewController(_ uiViewController: LiveViewController, context: Context)
    {
        uiViewController.ButtonPressed(FilterButtonPressed)
    }
   
    /// Create a coordinator for the class to talk with the main live view.
    func makeCoordinator() -> Coordinator
    {
        Coordinator(self)
    }
    
    /// Coordinator class to talk with the live view UIViewController.
    class Coordinator: NSObject, ViewControllerDelegate
    {
        /// Parent content view.
        var Parent: LiveViewControllerUI

        /// Initializer.
        /// - Parameter Parent: Parent of the coordinator.
        init(_ Parent: LiveViewControllerUI)
        {
            self.Parent = Parent
        }
        
        /// Called when the live view wants to show the "image saved" message.
        func ToggleImageSavedNotice()
        {
            Parent.ToggleSavedImageNotice = true
        }
    }
}

/// Protocol for the view controller.
protocol ViewControllerDelegate: AnyObject
{
    /// Toggle the image saved message.
    func ToggleImageSavedNotice()
}
