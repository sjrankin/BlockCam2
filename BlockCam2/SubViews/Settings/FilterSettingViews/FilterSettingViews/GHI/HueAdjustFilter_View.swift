//
//  HueAdjustFilter_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/30/21.
//

import Foundation
import SwiftUI

struct HueAdjustFilter_View: View
{
    @Binding var ButtonCommand: String
    @EnvironmentObject var Changed: ChangedSettings
    @State var CurrentAngle: String = "\(Int(Settings.GetDouble(.HueAngle, 0.0)))"
    @State var ActualAngle: Double = Double(Int(Settings.GetDouble(.HueAngle, 0.0)))
    @State var Updated: Bool = false
    
    var body: some View
    {
        GeometryReader
        {
            Geometry in
            ScrollView
            {
                VStack
                {
                    HStack
                    {
                        VStack(alignment: .leading)
                        {
                            Text("Hue angle")
                                .frame(width: Geometry.size.width * 0.5,
                                       alignment: .leading)
                            Text("Enter the hue angle in degrees")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(width: Geometry.size.width * 0.5,
                                       alignment: .leading)
                        }
                        .padding()
                        
                        Spacer()
                        
                        VStack
                        {
                            TextField("0.0", text: $CurrentAngle,
                                      onCommit:
                                        {
                                            if let Actual = Double(self.CurrentAngle)
                                            {
                                                ActualAngle = Double(Int(Actual))
                                                Settings.SetDouble(.HueAngle, Double(Int(Actual)))
                                                Updated.toggle()
                                            }
                                        })
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.custom("Avenir-Black", size: 18.0))
                                .frame(width: Geometry.size.width * 0.35)
                                .keyboardType(.numbersAndPunctuation)

                            Slider(value: Binding(
                                    get:
                                        {
                                            self.ActualAngle
                                        },
                                    set:
                                        {
                                            (newValue) in
                                            self.ActualAngle = newValue
                                            CurrentAngle = "\(Int(self.ActualAngle))"
                                            Settings.SetDouble(.HueAngle, Double(Int(self.ActualAngle)))
                                            Updated.toggle()
                                        }
                            ), in: 0 ... 359)
                            .frame(width: Geometry.size.width * 0.3)
                        }
                    }
                    Spacer()
                    Spacer()
                    Divider()
                        .background(Color.black)
                    SampleImage(UICommand: $ButtonCommand,
                                Filter: .HueAdjust,
                                Updated: $Updated.wrappedValue)
                        .frame(width: 300, height: 300, alignment: .center)
                }
            }
        }
        .onReceive(Changed.$ChangedFilter, perform:
                    {
                        Value in
                        if Value == BuiltInFilters.HueAdjust.rawValue
                        {
                            ActualAngle = Double(Int(Settings.GetDouble(.HueAngle, 0.0)))
                            CurrentAngle = "\(ActualAngle)"
                            Updated.toggle()
                        }
                    })
    }
}

struct HueAdjustFilter_Preview: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        HueAdjustFilter_View(ButtonCommand: $NotUsed)
            .environmentObject(ChangedSettings())
    }
}
