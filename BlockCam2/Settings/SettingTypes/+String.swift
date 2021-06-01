//
//  +String.swift
//  BlockCam2
//  Adapted from FlatlandView, 9/27/20.
//
//  Created by Stuart Rankin on 4/27/21.
//

import Foundation
import UIKit

extension Settings
{
    // MARK: - String functions.
    
    /// Initialize a String setting. Subscribers are not notified.
    /// - Parameter Setting: The setting of the string to initialize.
    /// - Parameter Value: The initial value of the setting.
    public static func InitializeString(_ Setting: SettingKeys, _ Value: String)
    {
        UserDefaults.standard.set(Value, forKey: Setting.rawValue)
    }
    
    /// Returns a string from the specified setting.
    /// - Parameter Setting: The setting whose string value will be returned.
    /// - Parameter Default: If the setting does not exist, this value will be set, then returned.
    /// - Returns: String found at the specified setting, or `Default` if it does not exist.
    public static func GetString(_ Setting: SettingKeys, _ Default: String) -> String
    {
        guard TypeIsValid(Setting, Type: String.self) else
        {
            Debug.FatalError("\(Setting) is not a string")
        }
        if let Raw = UserDefaults.standard.string(forKey: Setting.rawValue)
        {
            return Raw
        }
        UserDefaults.standard.set(Default, forKey: Setting.rawValue)
        return Default
    }
    
    /// Returns a string from the specified setting.
    /// - Parameter Setting: The setting whose string value will be returned.
    /// - Returns: String found at the specified setting, or nil if it does not exist.
    public static func GetString(_ Setting: SettingKeys) -> String?
    {
        guard TypeIsValid(Setting, Type: String.self) else
        {
            Debug.FatalError("\(Setting) is not a string")
        }
        return UserDefaults.standard.string(forKey: Setting.rawValue)
    }
    
    /// Returns a string from the specified setting.
    /// - Note: **Intended only for internal Settings usage.**
    /// - Parameter Setting: The setting whose string value will be returned.
    /// - Returns: String found at the specified setting, or nil if it does not exist.
    static func GetMaskedString(_ Setting: SettingKeys) -> String?
    {
        return UserDefaults.standard.string(forKey: Setting.rawValue)
    }
    
    /// Queries a string setting value.
    /// - Parameter Setting: The setting whose String value will be passed to the completion handler.
    /// - Parameter Completion: Code to execute after the value is retrieved. The value is passed
    ///                         to the completion handler.
    public static func QueryString(_ Setting: SettingKeys, Completion: (String?) -> Void)
    {
        guard TypeIsValid(Setting, Type: String.self) else
        {
            Debug.FatalError("\(Setting) is not a string")
        }
        let StringValue = UserDefaults.standard.string(forKey: Setting.rawValue)
        Completion(StringValue)
    }
    
    /// Save a string at the specified setting.
    /// - Parameter Setting: The setting where the string value will be saved.
    /// - Parameter Value: The value to save.
    public static func SetString(_ Setting: SettingKeys, _ Value: String)
    {
        guard TypeIsValid(Setting, Type: String.self) else
        {
            Debug.FatalError("\(Setting) is not a string")
        }
        let OldValue = UserDefaults.standard.string(forKey: Setting.rawValue)
        let NewValue = Value
        UserDefaults.standard.set(NewValue, forKey: Setting.rawValue)
        NotifySubscribers(Setting: Setting, OldValue: OldValue, NewValue: NewValue)
    }
    
    /// Set the default value for the passed setting.
    /// - Warning: Throws a fatal error if
    ///   - `For` points to a non-string setting.
    ///   - There is no default value.
    /// - Note:
    ///    - Default values must exist in the `SettingDefaults` dictionary under the same key name
    ///      as passed in `For`.
    ///    - Subscribers are notified of changes.
    /// - Parameter For: The setting key that will be assigned its default value.
    public static func SetStringDefault(For: SettingKeys)
    {
        guard TypeIsValid(For, Type: String.self) else
        {
            Debug.FatalError("\(For) is not a string")
        }
        
        guard let DefaultValue = SettingDefaults[For] as? String else
        {
            Debug.FatalError("\(For) has no default setting.")
        }
        
        let OldValue = UserDefaults.standard.string(forKey: For.rawValue)
        let NewValue = DefaultValue
        UserDefaults.standard.set(DefaultValue, forKey: For.rawValue)
        NotifySubscribers(Setting: For, OldValue: OldValue, NewValue: NewValue)
    }
}
