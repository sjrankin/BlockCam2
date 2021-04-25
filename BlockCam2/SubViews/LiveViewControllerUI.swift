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
        let ActualController = LiveViewController()
        ActualController.UIDelegate = context.coordinator
        return ActualController
    }
    
    /// Handles data from the UI to the live view.
    func updateUIViewController(_ uiViewController: LiveViewController, context: Context)
    {
        uiViewController.ButtonPressed(FilterButtonPressed)
    }
    
    func GetFilterData() -> FilterListData
    {
        return FilterData
    }
    
    func makeCoordinator() -> Coordinator
    {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, ViewControllerDelegate
    {
        var Parent: LiveViewControllerUI
        
        init(_ Parent: LiveViewControllerUI)
        {
            self.Parent = Parent
        }
        
        func FilterNamesPassed(_ viewController: LiveViewController, Names: [String])
        {
            Parent.FilterData.FilterNames = Names.map({IDString(id: $0, Value: $0)})
        }
    }
    
    @ObservedObject var FilterData = FilterListData()
}

protocol ViewControllerDelegate: AnyObject
{
    func FilterNamesPassed(_ viewController: LiveViewController, Names: [String])
}

class FilterListData: ObservableObject
{
    @Published var FilterNames = [IDString]()
}

struct IDString: Identifiable
{
    var id: String
    var Value: String
}
