//
//  +Filter.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/28/21.
//

import Foundation
import UIKit

extension LiveViewController
{
    /// Handles long taps in the metal live view component.
    /// - Note: Long taps are used for filter settings.
    /// - Parameter Gesture: The recognized gesture.
    @objc func HandleLongMetalViewTap(Gesture: UITapGestureRecognizer)
    {
        if Gesture.state == .began
        {
            UIDelegate?.ShowFilterSettings(For: "Hiya!")
        }
    }
}
