//
//  FilterSettingsServer.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/29/21.
//

/*
import Foundation
import SwiftUI

struct HueSettings_Angle: View
{
    @State var CurrentAngle: String = "\(Settings.GetDouble(.HueAngle))"
    
    var body: some View
    {
        VStack
        {
            HStack
            {
                VStack(alignment: .leading)
                {
                    Text("Hue angle")
                    Text("Enter the hue angle in degrees")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                
                TextField("0.0", text: $CurrentAngle,
                          onCommit:
                            {
                                print("\(self.CurrentAngle)")
                                if let Actual = Double(self.CurrentAngle)
                                {
                                    Settings.SetDouble(.HueAngle, Actual)
                                }
                            })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.custom("Avenir-Black", size: 18.0))
                    //.frame(width: Geometry.size.width * 0.35)
                    .keyboardType(.numbersAndPunctuation)
            }
        }
    }
}

class HueSettings
{
    static let ClassSettings = [HueSettings_Angle()]
    
    static func GetAll() -> [Any]
    {
        return ClassSettings
    }
}

class FilterSettingsServer
{
    func SettingsFor(_ Filter: BuiltInFilters) -> [Any]
    {
        switch Filter
        {
            case .HueAdjust:
                return HueSettings.GetAll()
                
            case .Kaleidoscope:
                return KaleidoscopeSettings()
                
            default:
                return NoSettings()
        }
    }
}
*/
