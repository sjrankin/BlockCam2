//
//  LiveViewControllerUI.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/15/21.
//

import Foundation
import UIKit
import SwiftUI


/// Wrapper for the live view UI (which requires components not yet available in SwiftUI).
struct LiveViewControllerUI: UIViewControllerRepresentable
{
    @Binding var UICommand: String
    @Binding var IsSelfieCamera: Bool
    @Binding var ShowFilterSettings: Bool
    @Binding var ShowShortMessageView: Bool
    @Binding var ShortMessage: String
    
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
        if !UICommand.isEmpty
        {
            print("UI control: \(UICommand)")
            uiViewController.ButtonPressed(UICommand)
            DispatchQueue.main.async
            {
                //Reset the control command.
                UICommand = ""
            }
        }
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
        func ShowShortMessage(With Text: String)
        {
            Parent.ShortMessage = Text
            Parent.ShowShortMessageView = true
        }
        
        /// Unconditionally hide the short status message.
        func HideShortMessage()
        {
            Parent.ShowShortMessageView = false
        }
        
        /// Hide the short status message after a delay.
        /// - Parameter With: Number of seconds to wait before hiding the message.
        func HideShortMessage(With Delay: Double)
        {
            perform(#selector(DoHideMessage), with: nil, afterDelay: Delay)
        }
        
        /// Hide the short status message.
        @objc func DoHideMessage()
        {
            Parent.ShowShortMessageView = false
        }
    }
}

/// Protocol for the view controller.
protocol ViewControllerDelegate: AnyObject
{
    /// Toggle the image saved message.
    func ShowShortMessage(With Text: String)
    
    /// Unconditionally hide the short status message.
    func HideShortMessage()
    
    /// Hide the short status message after a delay.
    /// - Parameter With: Number of seconds to wait before hiding the message.
    func HideShortMessage(With Delay: Double)
}

enum UICommands: String
{
    case TakePicture = "TakePicture"
    case SaveStill = "SaveStill"
    case SelectFromAlbum = "SelectFromAlbum"
    case ToggleCamera = "ToggleCamera"
    case SelectFilter = "Filters"
    case ShareImage = "ShareImage"
    case SaveOriginalSample = "SaveOriginalSample"
    case SaveFilteredSample = "SaveFilteredSample"
    case SetLiveViewMode = "SetLiveViewMode"
    case SetStillImageMode = "SetStillImageMode"
}
