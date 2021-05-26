//
//  LineScreenFilter_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/25/21.
//

import Foundation
import SwiftUI

struct LineScreenFilter_View: View
{
    @Binding var ButtonCommand: String
    @EnvironmentObject var Changed: ChangedSettings
    @State var CurrentAngle: String = "\(Settings.GetDouble(.LineScreenAngle, 0.0).RoundedTo(2))"
    @State var ActualAngle: Double = Settings.GetDouble(.LineScreenAngle, 0.0).RoundedTo(2)
    @State var Updated: Bool = false
    @State var PresetAngle: Int = LineScreen.GetInitialPresetAngle()
    
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
                            Text("Line screen angle")
                                .font(.headline)
                                .frame(width: Geometry.size.width * 0.5,
                                       alignment: .leading)
                            Text("Enter the line screen angle in degrees")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(width: Geometry.size.width * 0.5,
                                       alignment: .leading)
                        }
                        .padding()
                        
                        VStack
                        {
                            TextField("0.0", text: $CurrentAngle,
                                      onCommit:
                                        {
                                            if let Actual = Double(self.CurrentAngle)
                                            {
                                                ActualAngle = Actual.RoundedTo(3)
                                                Settings.SetDouble(.LineScreenAngle, ActualAngle)
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
                                        self.ActualAngle = newValue.RoundedTo(3)
                                        CurrentAngle = "\(self.ActualAngle)"
                                        Settings.SetDouble(.LineScreenAngle, self.ActualAngle)
                                        Updated.toggle()
                                    }
                            ), in: 0 ... 359)
                            .frame(width: Geometry.size.width * 0.3)
                        }
                        .padding(.trailing)
                    }
                    
                    VStack(alignment: .leading)
                    {
                        Text("Preset")
                            .font(.headline)
                            .padding(.leading)
                    Picker("Preset",
                           selection: $PresetAngle)
                    {
                        Text("0°").tag(0)
                        Text("45°").tag(45)
                        Text("90°").tag(90)
                        Text("135°").tag(135)
                    }
                    .onChange(of: PresetAngle)
                    {
                        Value in
                        switch Value
                        {
                            case 0:
                                CurrentAngle = "0"
                                ActualAngle = 0.0
                                Settings.SetDouble(.LineScreenAngle, 0.0)
                                Updated.toggle()
                                
                            case 45:
                                CurrentAngle = "45"
                                ActualAngle = 45.0
                                Settings.SetDouble(.LineScreenAngle, 45.0)
                                Updated.toggle()
                                
                            case 90:
                                CurrentAngle = "90"
                                ActualAngle = 90.0
                                Settings.SetDouble(.LineScreenAngle, 90.0)
                                Updated.toggle()
                                
                            case 135:
                                CurrentAngle = "135"
                                ActualAngle = 135.0
                                Settings.SetDouble(.LineScreenAngle, 135.0)
                                Updated.toggle()
                                
                            default:
                                break
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    }
                    
                    Divider()
                        .background(Color.black)
                    SampleImage(UICommand: $ButtonCommand,
                                Filter: .LineScreen,
                                Updated: $Updated.wrappedValue)
                        .frame(width: 300, height: 300, alignment: .center)
                }
            }
            .onReceive(Changed.$ChangedFilter, perform:
                        {
                            Value in
                            if Value == BuiltInFilters.DotScreen.rawValue
                            {
                                ActualAngle = Settings.GetDouble(.LineScreenAngle, 0.0)
                                CurrentAngle = "\(ActualAngle)"
                                Updated.toggle()
                            }
                        })
        }
    }
}

struct LineScreenFilter_Preview: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        LineScreenFilter_View(ButtonCommand: $NotUsed)
            .environmentObject(ChangedSettings())
    }
}
