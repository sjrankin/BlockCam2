//
//  +CGFloat.swift
//  BlockCam2
//  Adapted from FlatlandView, 9/27/20.
//
//  Created by Stuart Rankin on 4/27/21.
//

import Foundation
import UIKit

extension Settings
{
    // MARK: - CGFloat functions.
    
    /// Initialize a CGFloat setting. Subscribers are not notified.
    /// - Parameter Setting: The setting of the CGFloat to initialize.
    /// - Parameter Value: The initial value of the setting.
    public static func InitializeCGFloat(_ Setting: SettingKeys, _ Value: CGFloat)
    {
        UserDefaults.standard.set(Double(Value), forKey: Setting.rawValue)
    }
    
    /// Initialize a CGFloat? setting. Subscribers are not notified.
    /// - Parameter Setting: The setting of the CGFloat? to initialize.
    /// - Parameter Value: The initial value of the setting.
    public static func InitializeCGFloatNil(_ Setting: SettingKeys, _ Value: CGFloat? = nil)
    {
        if !TypeIsValid(Setting, Type: CGFloat.self)
        {
            fatalError("\(Setting) is not a CGFloat")
        }
        if let Actual = Value
        {
            UserDefaults.standard.set(Double(Actual), forKey: Setting.rawValue)
        }
        else
        {
            UserDefaults.standard.set(nil, forKey: Setting.rawValue)
        }
    }
    
    /// Returns a CGFloat value from the specified setting.
    /// - Parameter Setting: The setting whose CGFloat value will be returned.
    /// - Returns: CGFloat found at the specified setting.
    public static func GetCGFloat(_ Setting: SettingKeys) -> CGFloat
    {
        if !TypeIsValid(Setting, Type: CGFloat.self)
        {
            fatalError("\(Setting) is not a CGFloat")
        }
        return CGFloat(UserDefaults.standard.double(forKey: Setting.rawValue))
    }
    
    /// Queries a CGFloat setting value.
    /// - Parameter Setting: The setting whose CGFloat value will be passed to the completion handler.
    /// - Parameter Completion: Code to execute after the value is retrieved. The value is passed
    ///                         to the completion handler.
    public static func QueryCGFloat(_ Setting: SettingKeys, Completion: (CGFloat) -> Void)
    {
        if !TypeIsValid(Setting, Type: CGFloat.self)
        {
            fatalError("\(Setting) is not a CGFloat")
        }
        let CGFloatValue = CGFloat(UserDefaults.standard.double(forKey: Setting.rawValue))
        Completion(CGFloatValue)
    }
    
    /// Returns a CGFloat value from the specified setting, returning a passed value if the setting
    /// value is 0.0.
    /// - Parameter Setting: The setting whose CGFloat value will be returned.
    /// - Parameter IfZero: The value to return if the stored value is 0.0.
    /// - Returns: CGFloat found at the specified setting, the value found in `IfZero` if the stored
    ///            value is 0.0.
    public static func GetCGFloat(_ Setting: SettingKeys, _ IfZero: CGFloat = 0) -> CGFloat
    {
        if !TypeIsValid(Setting, Type: CGFloat.self)
        {
            fatalError("\(Setting) is not a CGFloat")
        }
        let Value = UserDefaults.standard.double(forKey: Setting.rawValue)
        if Value == 0.0
        {
            return IfZero
        }
        return CGFloat(Value)
    }
    
    /// Returns a CGFloat value from the specified setting.
    /// - Note: If the value in the settings is `0.0`, the value in `IfZero` is written then returned.
    /// - Parameter Setting: The setting whose CGFloat value will be returned.
    /// - Parameter IfZero: Default value to return if the original value is `0.0`.
    /// - Returns: The value at the specified settings. If that value is `0.0`, the value in `IfZero` is
    ///            returned.
    public static func GetCGFloat(_ Setting: SettingKeys, _ IfZero: Defaults) -> CGFloat 
    {
        if !TypeIsValid(Setting, Type: CGFloat.self)
        {
            fatalError("\(Setting) is not a CGFloat")
        }
        let Value = UserDefaults.standard.double(forKey: Setting.rawValue)
        if Value == 0.0
        {
            UserDefaults.standard.set(IfZero.rawValue, forKey: Setting.rawValue)
            return CGFloat(IfZero.rawValue)
        }
        return CGFloat(Value)
    }
    
    /// Returns a nilable CGFloat value from the specified setting.
    /// - Parameter Setting: The setting whose CGFloat value will be returned.
    /// - Parameter Default: The default value to return if the stored value is nil. Not returned
    ///                      if the contents of `Default` is nil.
    /// - Returns: The value stored at the specified setting, the contents of `Double` if the stored
    ///            value is nil, nil if `Default` is nil.
    public static func GetCGFloatNil(_ Setting: SettingKeys, _ Default: CGFloat? = nil) -> CGFloat?
    {
        if !TypeIsValid(Setting, Type: CGFloat?.self)
        {
            fatalError("\(Setting) is not a CGFloat")
        }
        if let Raw = UserDefaults.standard.string(forKey: Setting.rawValue)
        {
            if let Final = Double(Raw)
            {
                return CGFloat(Final)
            }
        }
        if let UseDefault = Default
        {
            UserDefaults.standard.set("\(UseDefault)", forKey: Setting.rawValue)
            return UseDefault
        }
        return nil
    }
    
    /// Queries a CGFloat? setting value.
    /// - Parameter Setting: The setting whose CGFloat? value will be passed to the completion handler.
    /// - Parameter Completion: Code to execute after the value is retrieved. The value is passed
    ///                         to the completion handler.
    public static func QueryCGFloatNil(_ Setting: SettingKeys, Completion: (CGFloat?) -> Void)
    {
        if !TypeIsValid(Setting, Type: CGFloat?.self)
        {
            fatalError("\(Setting) is not a CGFloat")
        }
        let CGFloatNil = GetCGFloatNil(Setting)
        Completion(CGFloatNil)
    }
    
    /// Save a CGFloat value at the specified setting.
    /// - Parameter Setting: The setting where the CGFloat value will be stored.
    /// - Parameter Value: The value to save.
    public static func SetCGFloat(_ Setting: SettingKeys, _ Value: CGFloat)
    {
        if !TypeIsValid(Setting, Type: CGFloat.self)
        {
            fatalError("\(Setting) is not a CGFloat")
        }
        let OldValue = CGFloat(UserDefaults.standard.double(forKey: Setting.rawValue))
        let NewValue = Value
        UserDefaults.standard.set(Double(NewValue), forKey: Setting.rawValue)
        NotifySubscribers(Setting: Setting, OldValue: OldValue, NewValue: NewValue)
    }
    
    /// Save a nilable CGFloat value at the specified setting.
    /// - Note: `CGFloat?` values are saved as strings but converted before being returned.
    /// - Parameter Setting: The setting where the CGFloat? value will be stored.
    /// - Parameter Value: The CGFloat? value to save.
    public static func SetCGFloatNil(_ Setting: SettingKeys, _ Value: CGFloat? = nil)
    {
        if !TypeIsValid(Setting, Type: CGFloat?.self)
        {
            fatalError("\(Setting) is not a CGFloat")
        }
        let OldValue = GetCGFloatNil(Setting)
        let NewValue = Value
        UserDefaults.standard.set(Value, forKey: Setting.rawValue)
        NotifySubscribers(Setting: Setting, OldValue: OldValue, NewValue: NewValue)
    }
    
    /// Set the default value for the passed setting.
    /// - Warning: Throws a fatal error if
    ///   - `For` points to a non-CGFloat setting.
    ///   - There is no default value.
    /// - Note:
    ///    - Default values must exist in the `SettingDefaults` dictionary under the same key name
    ///      as passed in `For`.
    ///    - Subscribers are notified of changes.
    /// - Parameter For: The setting key that will be assigned its default value.
    public static func SetCGFloatDefault(For: SettingKeys)
    {
        guard TypeIsValid(For, Type: CGFloat.self) else
        {
            Debug.FatalError("\(For) is not a CGFloat")
        }
        
        guard let DefaultValue = SettingDefaults[For] as? CGFloat else
        {
            Debug.FatalError("\(For) has no default setting.")
        }
        
        let OldValue = UserDefaults.standard.double(forKey: For.rawValue)
        let NewValue = DefaultValue
        UserDefaults.standard.set(DefaultValue, forKey: For.rawValue)
        NotifySubscribers(Setting: For, OldValue: OldValue, NewValue: NewValue)
    }
}
