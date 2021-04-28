//
//  SettingChangedProtocol.swift
//  BlockCam2
//  Adapted from FlatlandView, 5/24/20.
//
//  Created by Stuart Rankin on 4/27/21.
//

import Foundation
import UIKit

protocol SettingChangedProtocol: AnyObject
{
    /// The ID of the subscriber. This value should not change during the run-time
    /// of the program.
    /// - Returns: The ID of the subscriber.
    func SubscriberID() -> UUID
    
    /// Handle changed settings. Settings may be changed from anywhere at any time.
    /// - Parameter Setting: The setting that changed.
    /// - Parameter OldValue: The value of the setting before the change.
    /// - Parameter NewValue: The new value of the setting.
    func SettingChanged(Setting: SettingKeys, OldValue: Any?, NewValue: Any?)
}
