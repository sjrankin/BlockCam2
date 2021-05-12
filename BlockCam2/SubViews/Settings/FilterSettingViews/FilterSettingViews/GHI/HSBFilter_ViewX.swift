//
//  HSBFilter_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/6/21.
//

import Foundation
import SwiftUI

struct HSBFilter_View: View
{
    @Binding var ButtonCommand: String
    @EnvironmentObject var Changed: ChangedSettings
    @State var EnableHue: Bool = Settings.GetBool(.HSBChangeHue)
    @State var CurrentHue: String = "\(Settings.GetDouble(.HSBHueValue, 0.0))"
    @State var ActualHue: Double = Settings.GetDouble(.HSBHueValue, 0.0)
    @State var EnableSaturation: Bool = Settings.GetBool(.HSBChangeSaturation)
    @State var CurrentSaturation: String = "\(Settings.GetDouble(.HSBSaturationValue, 0.0))"
    @State var ActualSaturation: Double = Settings.GetDouble(.HSBSaturationValue, 0.0)
    @State var EnableBrightness: Bool = Settings.GetBool(.HSBChangeBrightness)
    @State var CurrentBrightness: String = "\(Settings.GetDouble(.HSBBrightnessValue, 0.0))"
    @State var ActualBrightness: Double = Settings.GetDouble(.HSBBrightnessValue, 0.0)
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
                            Text("Hue multiplier")
                                .frame(width: Geometry.size.width * 0.5,
                                       alignment: .leading)
                            Text("Enter the hue multliper (-5.0 to 5.0)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(width: Geometry.size.width * 0.5,
                                       alignment: .leading)
                        }
                        .padding()
                        
                        Spacer()
                        
                        VStack
                        {
                            TextField("0.0", text: $CurrentHue,
                                      onCommit:
                                        {
                                            if let Actual = Double(self.CurrentHue)
                                            {
                                                ActualHue = Double(Actual.RoundedTo(3))
                                                Settings.SetDouble(.HSBHueValue, Double(ActualHue))
                                                Updated.toggle()
                                            }
                                        })
                                .padding(.top, 2)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.custom("Avenir-Black", size: 18.0))
                                .frame(width: Geometry.size.width * 0.35)
                                .keyboardType(.numbersAndPunctuation)
                            
                            Slider(value: Binding(
                                get:
                                    {
                                        self.ActualHue.RoundedTo(3)
                                    },
                                set:
                                    {
                                        (newValue) in
                                        self.ActualHue = newValue.RoundedTo(3)
                                        CurrentHue = "\(self.ActualHue)"
                                        Settings.SetDouble(.HSBHueValue, Double(self.ActualHue))
                                        Updated.toggle()
                                    }
                            ), in: -5.0 ... 5.0)
                            .frame(width: Geometry.size.width * 0.3)
                            Toggle(isOn: $EnableHue)
                            {
                                Text("Enable")
                            }
                            .onReceive([self.EnableHue].publisher.first())
                            {
                                Value in
                                print("EnableHue=\(Value)")
                            }
                            .padding()
                        }
                    }
                    .background(Color(UIColor.systemGray5))
                    
                    HStack
                    {
                        VStack(alignment: .leading)
                        {
                            Text("Saturation multiplier")
                                .frame(width: Geometry.size.width * 0.5,
                                       alignment: .leading)
                            Text("Enter the saturation multliper (-5.0 to 5.0)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(width: Geometry.size.width * 0.5,
                                       alignment: .leading)
                        }
                        .padding(.all, 2)
                        
                        Spacer()
                        
                        VStack
                        {
                            TextField("0.0", text: $CurrentSaturation,
                                      onCommit:
                                        {
                                            if let Actual = Double(self.CurrentSaturation)
                                            {
                                                ActualSaturation = Double(Actual).RoundedTo(3)
                                                Settings.SetDouble(.HSBSaturationValue, Double(ActualSaturation))
                                                Updated.toggle()
                                            }
                                        })
                                .padding(.top, 2)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.custom("Avenir-Black", size: 18.0))
                                .frame(width: Geometry.size.width * 0.35)
                                .keyboardType(.numbersAndPunctuation)
                            
                            Slider(value: Binding(
                                get:
                                    {
                                        self.ActualSaturation.RoundedTo(3)
                                    },
                                set:
                                    {
                                        (newValue) in
                                        self.ActualSaturation = newValue.RoundedTo(3)
                                        CurrentSaturation = "\(self.ActualSaturation)"
                                        Settings.SetDouble(.HSBSaturationValue, Double(self.ActualSaturation))
                                        Updated.toggle()
                                    }
                            ), in: -5.0 ... 5.0)
                            .frame(width: Geometry.size.width * 0.3)
                            Toggle(isOn: $EnableSaturation)
                            {
                                Text("Enable")
                            }
                            .onReceive([self.EnableSaturation].publisher.first())
                            {
                                Value in
                                print("EnableSaturation=\(Value)")
                            }
                            .padding()
                        }
                    }
                    
                    HStack
                    {
                        VStack(alignment: .leading)
                        {
                            Text("Brightness multiplier")
                                .frame(width: Geometry.size.width * 0.5,
                                       alignment: .leading)
                            Text("Enter the brightness multliper (-5.0 to 5.0)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(width: Geometry.size.width * 0.5,
                                       alignment: .leading)
                        }
                        .padding(.all, 2)
                        
                        Spacer()
                        
                        VStack
                        {
                            TextField("0.0", text: $CurrentBrightness,
                                      onCommit:
                                        {
                                            if let Actual = Double(self.CurrentBrightness)
                                            {
                                                ActualBrightness = Double(Actual).RoundedTo(3)
                                                Settings.SetDouble(.HSBBrightnessValue, Double(ActualBrightness))
                                                Updated.toggle()
                                            }
                                        })
                                .padding(.top, 2)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.custom("Avenir-Black", size: 18.0))
                                .frame(width: Geometry.size.width * 0.35)
                                .keyboardType(.numbersAndPunctuation)
                            
                            Slider(value: Binding(
                                get:
                                    {
                                        self.ActualBrightness.RoundedTo(3)
                                    },
                                set:
                                    {
                                        (newValue) in
                                        self.ActualBrightness = newValue.RoundedTo(3)
                                        CurrentBrightness = "\(self.ActualBrightness)"
                                        Settings.SetDouble(.HSBBrightnessValue, Double(self.ActualBrightness))
                                        Updated.toggle()
                                    }
                            ), in: -5.0 ... 5.0)
                            .frame(width: Geometry.size.width * 0.3)
                            Toggle(isOn: $EnableBrightness)
                            {
                                Text("Enable")
                            }
                            .onReceive([self.EnableBrightness].publisher.first())
                            {
                                Value in
                                print("EnableBrightness=\(Value)")
                            }
                            .padding()
                        }
                    }
                    .background(Color(UIColor.systemGray5))
                    
                    Spacer()
                    Spacer()
//                    SampleImage(Filter: .HSB, Updated: $Updated.wrappedValue)
//                        .frame(width: 300, height: 300, alignment: .center)
                }
            }
        }
    }
}

struct HSBFilter_Preview: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        HSBFilter_View(ButtonCommand: $NotUsed)
            .environmentObject(ChangedSettings())
    }
}
