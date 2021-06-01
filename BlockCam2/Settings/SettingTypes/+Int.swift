//
//  +Int.swift
//  BlockCam2
//  Adapted from FlatlandView, 9/27/20.
//
//  Created by Stuart Rankin on 4/27/21.
//

import Foundation
import UIKit

extension Settings
{
    // MARK: - Int functions.
    
    /// Initialize an Integer setting. Subscribers are not notified.
    /// - Warning: A fatal error will be thrown if the type of `Setting` is not Int.
    /// - Parameter Setting: The setting of the integer to initialize.
    /// - Parameter Value: The initial value of the setting.
    public static func InitializeInt(_ Setting: SettingKeys, _ Value: Int)
    {
        guard TypeIsValid(Setting, Type: Int.self) else
        {
            Debug.FatalError("\(Setting) is not an Int")
        }
        UserDefaults.standard.set(Value, forKey: Setting.rawValue)
    }
    
    /// Returns an integer from the specified setting.
    /// - Warning: A fatal error will be thrown if the type of `Setting` is not Int.
    /// - Parameter Setting: The setting whose integer value will be returned.
    /// - Parameter Block: Trailing closure. Passes the value to the closure. Defaults to `nil`.
    /// - Returns: Integer found at the specified setting.
    public static func GetInt(_ Setting: SettingKeys, Block: ((Int) -> ())? = nil) -> Int
    {
        guard TypeIsValid(Setting, Type: Int.self) else
        {
            Debug.FatalError("\(Setting) is not an Int")
        }
        let ReturnMe = UserDefaults.standard.integer(forKey: Setting.rawValue)
        if let Closure = Block
        {
            Closure(ReturnMe)
        }
        return ReturnMe
    }
    
    /// Returns an integer from the specified setting.
    /// - Warning: A fatal error will be thrown if the type of `Setting` is not Int.
    /// - Parameter Setting: The setting whose integer value will be returned.
    /// - Parameter IfZero: The value to return if the value in the setting is zero. If the value in the
    ///                     setting is zero, the value of `IfZero` is saved there.
    /// - Returns: Integer found at the specified setting. If that value is `0`, the value passed in `IfZero`
    ///            is saved in the setting then returned.
    public static func GetInt(_ Setting: SettingKeys, IfZero: Int) -> Int
    {
        guard TypeIsValid(Setting, Type: Int.self) else
        {
            Debug.FatalError("\(Setting) is not an Int")
        }
        let Value = UserDefaults.standard.integer(forKey: Setting.rawValue)
        if Value == 0
        {
            UserDefaults.standard.setValue(IfZero, forKey: Setting.rawValue)
            return IfZero
        }
        return Value
    }
    
    /// Returns an integer from the specified setting.
    /// - Warning: A fatal error will be thrown if the type of `Setting` is not Int.
    /// - Parameter Setting: The setting whose integer value will be returned.
    /// - Parameter IfZero: The value to return if the value in the setting is zero. If the value in the
    ///                     setting is zero, the value of `IfZero` is saved there. The value of this
    ///                     parameter is typecast to `Int`.
    /// - Returns: Integer found at the specified setting. If that value is `0`, the value passed in `IfZero`
    ///            is saved in the setting then returned.
    public static func GetInt(_ Setting: SettingKeys, IfZero: Defaults) -> Int
    {
        guard TypeIsValid(Setting, Type: Int.self) else
        {
            Debug.FatalError("\(Setting) is not an Int")
        }
        let Value = UserDefaults.standard.integer(forKey: Setting.rawValue)
        if Value == 0
        {
            UserDefaults.standard.setValue(Int(IfZero.rawValue), forKey: Setting.rawValue)
            return Int(IfZero.rawValue)
        }
        return Value
    }
    
    /// Queries an integer setting value.
    /// - Warning: A fatal error will be thrown if the type of `Setting` is not Int.
    /// - Parameter Setting: The setting whose integer value will be passed to the completion handler.
    /// - Parameter Completion: Code to execute after the value is retrieved. The value is passed
    ///                         to the completion handler.
    public static func QueryInt(_ Setting: SettingKeys, Completion: (Int) -> Void)
    {
        guard TypeIsValid(Setting, Type: Int.self) else
        {
            Debug.FatalError("\(Setting) is not an Int")
        }
        let IntValue = UserDefaults.standard.integer(forKey: Setting.rawValue)
        Completion(IntValue)
    }
    
    /// Save an integer at the specified setting.
    /// - Warning: A fatal error will be thrown if the type of `Setting` is not Int.
    /// - Parameter Setting: The setting where the integer value will be saved.
    /// - Parameter Value: The value to save.
    public static func SetInt(_ Setting: SettingKeys, _ Value: Int)
    {
        guard TypeIsValid(Setting, Type: Int.self) else
        {
            Debug.FatalError("\(Setting) is not an Int")
        }
        let OldValue = UserDefaults.standard.integer(forKey: Setting.rawValue)
        let NewValue = Value
        UserDefaults.standard.set(NewValue, forKey: Setting.rawValue)
        NotifySubscribers(Setting: Setting, OldValue: OldValue, NewValue: NewValue)
    }
    
    /// Increment an integer value at the passed setting.
    /// - Warning: A fatal error will be thrown if the type of `Setting` is not Int.
    /// - Parameter Setting: The setting whose value will be incremented.
    /// - Returns: Incremented value.
    @discardableResult public static func IncrementInt(_ Setting: SettingKeys) -> Int
    {
        guard TypeIsValid(Setting, Type: Int.self) else
        {
            Debug.FatalError("\(Setting) is not an Int")
        }
        var OldValue = UserDefaults.standard.integer(forKey: Setting.rawValue)
        OldValue = OldValue + 1
        UserDefaults.standard.set(OldValue, forKey: Setting.rawValue)
        return OldValue
    }
    
    /// Set the default value for the passed setting.
    /// - Warning: Throws a fatal error if
    ///   - `For` points to a non-integer setting.
    ///   - There is no default value.
    /// - Note:
    ///    - Default values must exist in the `SettingDefaults` dictionary under the same key name
    ///      as passed in `For`.
    ///    - Subscribers are notified of changes.
    /// - Parameter For: The setting key that will be assigned its default value.
    public static func SetIntDefault(For: SettingKeys)
    {
        guard TypeIsValid(For, Type: Int.self) else
        {
            Debug.FatalError("\(For) is not an integer")
        }
        
        guard let DefaultValue = SettingDefaults[For] as? Int else
        {
            Debug.FatalError("\(For) has no default setting.")
        }
        
        let OldValue = UserDefaults.standard.integer(forKey: For.rawValue)
        let NewValue = DefaultValue
        UserDefaults.standard.set(DefaultValue, forKey: For.rawValue)
        NotifySubscribers(Setting: For, OldValue: OldValue, NewValue: NewValue)
    }
}
