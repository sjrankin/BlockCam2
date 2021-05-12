//
//  Settings.swift
//  BlockCam2
//  Adapted from FlatlandView, 5/24/20.
//
//  Created by Stuart Rankin on 4/27/21.
//

import Foundation
import UIKit

/// This class encapsulates settings into a set of functions that rely on enums to select the
/// value rather than strings. This class also allows other classes to "subscribe" to changed
/// value events. Most code to set values for specific types can be found in various extentions.
class Settings
{
    // MARK: - Initialization.
    
    /// Initialize settings. Run only if the initialization flag hasn't been set, or the force
    /// reinitialize flag is true.
    /// - Note: This function also loads databases with data managed by this class.
    /// - Parameter ForceReinitialize: If true, settings will be reset to their default values. In
    ///                                this case, no messages will be returned to subscribers indicating
    ///                                changes have been made.
    public static func Initialize(_ ForceReinitialize: Bool = false)
    {
        if WasInitialized()
        {
            Debug.Print("Settings already initialized.")
            if !ForceReinitialize
            {
                return
            }
        }
        
        Debug.Print("Initializing settings.")
        InitializeBool(.InitializationFlag, true)
        InitializeBool(.SaveOriginalImage, true)
        InitializeBool(.ShowAudioWaveform, false)
    }
    
    /// Determines if settings were initialized.
    /// - Returns: True if settings were initialized, false if not.
    public static func WasInitialized() -> Bool
    {
        return GetBool(.InitializationFlag)
    }
    
    // MARK: - Subscriber management.
    
    /// List of subscribers we send change notices to.
    static var Subscribers = [SettingChangedProtocol]()
    
    /// Add a subscriber. Subscribers receive change notices for most changes. (Initialization
    /// events are not sent.)
    /// - Parameter NewSubscriber: A new subscriber to receive change notices. Must implement
    ///                            the `SettingChangedProtocol`.
    public static func AddSubscriber(_ NewSubscriber: SettingChangedProtocol)
    {
        for Subscriber in Subscribers
        {
            if Subscriber.SubscriberID() == NewSubscriber.SubscriberID()
            {
                return
            }
        }
        Subscribers.append(NewSubscriber)
    }
    
    /// Remove a subscriber. Should be called when a class/subscriber goes out of scope.
    /// - Parameter OldSubscriber: The subscriber to remove. If not present, no action is taken.
    public static func RemoveSubscriber(_ OldSubscriber: SettingChangedProtocol)
    {
        Subscribers.removeAll(where: {$0.SubscriberID() == OldSubscriber.SubscriberID()})
    }
    
    /// Called when a change to a setting value is made. The old value and new value and setting
    /// that changed is sent to the subscriber.
    /// - Note:
    ///   - Changes made via an initialization function are *not* reported to subscribers.
    ///   - Subscribers are notified even if `NewValue` has the same value as `OldValue`.
    /// - Parameter Setting: The setting that was changed.
    /// - Parameter OldValue: The value before the change.
    /// - Parameter Newvalue: The value after the change.
    public static func NotifySubscribers(Setting: SettingKeys, OldValue: Any?, NewValue: Any?)
    {
        for Subscriber in Subscribers
        {
            Subscriber.SettingChanged(Setting: Setting, OldValue: OldValue, NewValue: NewValue)
        }
    }
    
    // MARK: - Validation functions.
    
    /// Determines if the passed type is valid for the passed setting type/key.
    /// - Parameter For: The setting key show type will be tested against `Type`.
    /// - Parameter Type: The type to test against the type in `SettingKeyTypes`.
    /// - Returns: True if the passed type matches the type in the `SettingKeyTypes` table, false otherwise.
    public static func TypeIsValid(_ For: SettingKeys, Type: Any) -> Bool
    {
        let TypeName = "\(Type)"
        if let BaseType = SettingKeyTypes[For]
        {
            let BaseName = "\(BaseType)"
            return TypeName == BaseName
        }
        return false
    }
    
    // MARK: - Filter management.
    
    public static func ResetCurrentFilter()
    {
       if let FilterToReset = Settings.GetString(.CurrentFilter)
       {
        switch FilterToReset
        {
            case BuiltInFilters.UnsharpMask.rawValue:
                UnsharpMask.ResetFilter()
                
            case BuiltInFilters.TwirlDistortion.rawValue:
                TwirlDistortion.ResetFilter()
            
            case BuiltInFilters.EdgeWork.rawValue:
                EdgeWork.ResetFilter()
                
            case BuiltInFilters.Sepia.rawValue:
                Sepia.ResetFilter()
            
            case BuiltInFilters.BumpDistortion.rawValue:
                BumpDistortion.ResetFilter()
                
            case BuiltInFilters.CircleSplashDistortion.rawValue:
                CircleSplashDistortion.ResetFilter()
                
            case BuiltInFilters.CMYKHalftone.rawValue:
                CMYKHalftone.ResetFilter()
                
            case BuiltInFilters.ColorControls.rawValue:
                ColorControls.ResetFilter()
                
            case BuiltInFilters.ColorMap.rawValue:
                ColorMap.ResetFilter()
                
            case BuiltInFilters.ColorMonochrome.rawValue:
                ColorMonochrome.ResetFilter()
                
            case BuiltInFilters.Dither.rawValue:
                Dither.ResetFilter()
                
            case BuiltInFilters.DotScreen.rawValue:
                DotScreen.ResetFilter()
                
            case BuiltInFilters.Droste.rawValue:
                Droste.ResetFilter()
                
            case BuiltInFilters.Edges.rawValue:
                Edges.ResetFilter()
                
            case BuiltInFilters.ExposureAdjust.rawValue:
                ExposureAdjust.ResetFilter()
                
            case BuiltInFilters.HueAdjust.rawValue:
                HueAdjust.ResetFilter()
                
            case BuiltInFilters.HSB.rawValue:
                HSB.ResetFilter()
                
            case BuiltInFilters.Kaleidoscope.rawValue:
                Kaleidoscope.ResetFilter()
                
            case BuiltInFilters.Mirroring2.rawValue:
                Mirror2.ResetFilter()
                
            case BuiltInFilters.TriangleKaleidoscope.rawValue:
                TriangleKaleidoscope.ResetFilter()
                
            case BuiltInFilters.Vibrance.rawValue:
                Vibrance.ResetFilter()
                
            default:
                break
        }
       }
    }
}

/// Setting errors that may occur.
enum SettingErrors: String, CaseIterable, Error
{
    /// No error - operation was a success.
    case Success = "Success"
    /// Bad type specified.
    case BadType = "BadType"
    /// No type found for setting key.
    case NoType = "NoType"
    /// Error converting from one type to another.
    case ConversionError = "ConversionError"
}
