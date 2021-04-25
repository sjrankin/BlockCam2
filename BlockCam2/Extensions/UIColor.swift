//
//  UIColor.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/24/21.
//

import Foundation
import UIKit

extension UIColor
{
    /// Converts a raw hex value (prefixed by one of: "0x", "0X", or "#") into a `UIColor`. **Color order is: rrggbbaa or rrggbb.**
    /// - Note: From code in Fouris.
    /// - Parameter RawString: The raw hex string to convert.
    /// - Returns: Tuple of color channel information.
    public static func ColorChannelsFromRGBA(_ RawString: String) -> (Red: CGFloat, Green: CGFloat, Blue: CGFloat, Alpha: CGFloat)?
    {
        var Working = RawString.trimmingCharacters(in: .whitespacesAndNewlines)
        if Working.isEmpty
        {
            return nil
        }
        if Working.uppercased().starts(with: "0X")
        {
            Working = Working.replacingOccurrences(of: "0x", with: "")
            Working = Working.replacingOccurrences(of: "0X", with: "")
        }
        if Working.starts(with: "#")
        {
            Working = Working.replacingOccurrences(of: "#", with: "")
        }
        switch Working.count
        {
            case 8:
                if let Value = UInt(Working, radix: 16)
                {
                    let Red: CGFloat = CGFloat((Value & 0xff000000) >> 24) / 255.0
                    let Green: CGFloat = CGFloat((Value & 0x00ff0000) >> 16) / 255.0
                    let Blue: CGFloat = CGFloat((Value & 0x0000ff00) >> 8) / 255.0
                    let Alpha: CGFloat = CGFloat((Value & 0x000000ff) >> 0) / 255.0
                    return (Red: Red, Green: Green, Blue: Blue, Alpha: Alpha)
                }
                
            case 6:
                if let Value = UInt(Working, radix: 16)
                {
                    let Red: CGFloat = CGFloat((Value & 0xff0000) >> 16) / 255.0
                    let Green: CGFloat = CGFloat((Value & 0x00ff00) >> 8) / 255.0
                    let Blue: CGFloat = CGFloat((Value & 0x0000ff) >> 0) / 255.0
                    return (Red: Red, Green: Green, Blue: Blue, Alpha: 1.0)
                }
                
            default:
                break
        }
        return nil
    }
    
    /// Create an NSColor using a value interpreted as a hex color value. See also `NSColor(RGB:)`.
    /// - Parameter RGBA: Value to convert to a color. Value is assumed to be in the format of `rrggbbaa`.
    /// - Returns: `NSColor` based on the passed value.
    convenience init(RGBA: UInt)
    {
        var Red: UInt = 0
        var Green: UInt = 0
        var Blue: UInt = 0
        var Alpha: UInt = 0xff
        
        Red = RGBA & 0xff000000
        Red = Red >> 24
        Green = RGBA & 0x00ff0000
        Green = Green >> 16
        Blue = RGBA & 0x0000ff00
        Blue = Blue >> 8
        Alpha = RGBA & 0x000000ff
        Alpha = Alpha >> 0
        
        let FinalRed: CGFloat = CGFloat(Red) / 255.0
        let FinalGreen: CGFloat = CGFloat(Green) / 255.0
        let FinalBlue: CGFloat = CGFloat(Blue) / 255.0
        let FinalAlpha: CGFloat = CGFloat(Alpha) / 255.0
        self.init(red: FinalRed, green: FinalGreen, blue: FinalBlue, alpha: FinalAlpha)
    }
    
    /// Create an NSColor using a value interpreted as a hex color value. The value to convert is assumed
    /// to be an RGB value. See also `NSColor(RGBA:)`.
    /// - Warning: If the value of `RGB` is greater than `0xffffff` a fatal error will be thrown.
    /// - Parameter RGB: Value to convert to a color in the format `rrggbb`. Alpha is assigned 1.0.
    /// - Returns: `NSColor` base on the passed value.
    convenience init(RGB: Int)
    {
        if RGB > 0xffffff
        {
            fatalError("RGB value of \(RGB) is too big to convert to a color.")
        }
        
        var Red = RGB & 0xff0000
        Red = Red >> 16
        var Green = RGB & 0x00ff00
        Green = Green >> 8
        let Blue = RGB & 0x0000ff >> 0
        
        let FinalRed: CGFloat = CGFloat(Red) / 255.0
        let FinalGreen: CGFloat = CGFloat(Green) / 255.0
        let FinalBlue: CGFloat = CGFloat(Blue) / 255.0
        self.init(red: FinalRed, green: FinalGreen, blue: FinalBlue, alpha: 1.0)
    }
}
