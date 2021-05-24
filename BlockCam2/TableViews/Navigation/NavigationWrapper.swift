//
//  NavigationWrapper.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/23/21.
//

import Foundation
import UIKit
import SwiftUI

struct NavigationWrapper: UIViewControllerRepresentable
{
    func makeUIViewController(context: UIViewControllerRepresentableContext<NavigationWrapper>) -> some UserSampleEditorRootController
    {
        let UserView = UserSampleEditorRootController()
        return UserView
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: UIViewControllerRepresentableContext<NavigationWrapper>)
    {
    }
    
    func makeCoordinator() -> Coordinator
    {
        Coordinator(self)
    }
    
    class Coordinator: NSObject
    {
        var Parent: NavigationWrapper
        
        init(_ Parent: NavigationWrapper)
        {
            self.Parent = Parent
        }
    }
}
