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
    @Binding var FilterButtonPressed: String
    @Binding var IsSelfieCamera: Bool
    
    /// Returns the LiveViewController instance.
    func makeUIViewController(context: Context) -> LiveViewController
    {
        let TheView = LiveViewController()
        return TheView
    }
    
    /// Handles data from the UI to the live view.
    func updateUIViewController(_ uiViewController: LiveViewController, context: Context)
    {
        uiViewController.ButtonPressed(FilterButtonPressed)
    }
}
