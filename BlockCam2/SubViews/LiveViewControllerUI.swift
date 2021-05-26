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
/// - Parameter UICommand: Command to execute in the live view code.
/// - Parameter IsSelfieCamera: Determines which camera to use (front or back).
/// - Parameter ShowFilterSettings: Show or hide filter settings.
/// - Parameter ShowShorMessageView: Display the short message view.
/// - Parameter ShortMessage: Message to display in the short message view.
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
        // https://www.reddit.com/r/SwiftUI/comments/e5100l/what_does_the_runtime_warning_modifying_state/
        func ShowShortMessage(With Text: String)
        {
            DispatchQueue.main.async
            {
                self.Parent.ShortMessage = Text
                self.Parent.ShowShortMessageView = true
            }
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

/// Commands from the UI (SwiftUI) to the live view (UIKit), where they are executed.
enum UICommands: String
{
    /// Camera button pressed.
    case TakePicture = "TakePicture"
    /// Save a still image.
    case SaveStill = "SaveStill"
    /// Open the photo album and select an image there.
    case SelectFromAlbum = "SelectFromAlbum"
    /// Switch cameras (front or back).
    case ToggleCamera = "ToggleCamera"
    /// Set new filter selected by the user.
    case SelectFilter = "Filters"
    /// Share the image somewhere.
    case ShareImage = "ShareImage"
    /// Save the sample image, unchanged.
    case SaveOriginalSample = "SaveOriginalSample"
    /// Save the sample image, filtered.
    case SaveFilteredSample = "SaveFilteredSample"
    /// Set the live view mode.
    case SetLiveViewMode = "SetLiveViewMode"
    /// Set the still image mode.
    case SetStillImageMode = "SetStillImageMode"
}
