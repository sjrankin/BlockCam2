//
//  ColorControlsFilter_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/6/21.
//

import Foundation
import SwiftUI

struct ColorControlsFilter_View: View
{
    @Binding var ButtonCommand: String
    @EnvironmentObject var Changed: ChangedSettings
    @State var Updated: Bool = false
    @State var Brightness: Double = Settings.GetDouble(.ColorControlsBrightness).RoundedTo(2)
    @State var BrightnessString: String = "\(Settings.GetDouble(.ColorControlsBrightness).RoundedTo(2))"
    @State var Contrast: Double = Settings.GetDouble(.ColorControlsContrast).RoundedTo(2)
    @State var ContrastString: String = "\(Settings.GetDouble(.ColorControlsContrast).RoundedTo(2))"
    @State var Saturation: Double = Settings.GetDouble(.ColorControlsSaturation).RoundedTo(2)
    @State var SaturationString: String = "\(Settings.GetDouble(.ColorControlsSaturation).RoundedTo(2))"
    
    var body: some View
    {
        GeometryReader
        {
            Geometry in
            ScrollView
            {
                HStack
                {
                    VStack(alignment: .leading)
                    {
                        Text("Brightness")
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                        Text("Brightness value of the image.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                    }
                    .padding()
                    Spacer()
                    VStack
                    {
                    TextField("", text: $BrightnessString,
                              onCommit:
                                {
                                    if let Actual = Double(self.BrightnessString)
                                    {
                                        Brightness = Actual.RoundedTo(2)
                                        if Brightness < -1.0
                                        {
                                            Brightness = -1.0
                                        }
                                        Settings.SetDouble(.ColorControlsBrightness, Brightness)
                                        Updated.toggle()
                                    }
                                })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.custom("Avenir-Black", size: 18.0))
                        .keyboardType(.numbersAndPunctuation)
                        Slider(value: Binding(
                            get:
                                {
                                    self.Brightness
                                },
                            set:
                                {
                                    (newValue) in
                                    self.Brightness = newValue.RoundedTo(2)
                                    BrightnessString = "\(self.Brightness)"
                                    Settings.SetDouble(.ColorControlsBrightness, Brightness)
                                    Updated.toggle()
                                }
                        ), in: -1.0 ... 1.0)
                    }
                }

                HStack
                {
                    VStack(alignment: .leading)
                    {
                        Text("Contrast")
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                        Text("Contrast value of the image.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                    }
                    .padding()
                    Spacer()
                    VStack
                    {
                    TextField("", text: $ContrastString,
                              onCommit:
                                {
                                    if let Actual = Double(self.ContrastString)
                                    {
                                        Contrast = Actual.RoundedTo(2)
                                        Settings.SetDouble(.ColorControlsContrast, Contrast)
                                        Updated.toggle()
                                    }
                                })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.custom("Avenir-Black", size: 18.0))
                        .keyboardType(.numbersAndPunctuation)
                        Slider(value: Binding(
                            get:
                                {
                                    self.Contrast
                                },
                            set:
                                {
                                    (newValue) in
                                    self.Contrast = newValue.RoundedTo(2)
                                    ContrastString = "\(self.Contrast)"
                                    Settings.SetDouble(.ColorControlsContrast, Contrast)
                                    Updated.toggle()
                                }
                        ), in: 0.0 ... 1.0)
                    }
                }

                HStack
                {
                    VStack(alignment: .leading)
                    {
                        Text("Saturation")
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                        Text("Saturation value of the image.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                    }
                    .padding()
                    Spacer()
                    VStack
                    {
                    TextField("", text: $SaturationString,
                              onCommit:
                                {
                                    if let Actual = Double(self.SaturationString)
                                    {
                                        Saturation = Actual.RoundedTo(2)
                                        Settings.SetDouble(.ColorControlsSaturation, Saturation)
                                        Updated.toggle()
                                    }
                                })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.custom("Avenir-Black", size: 18.0))
                        .keyboardType(.numbersAndPunctuation)
                        Slider(value: Binding(
                            get:
                                {
                                    self.Saturation
                                },
                            set:
                                {
                                    (newValue) in
                                    self.Saturation = newValue.RoundedTo(2)
                                    SaturationString = "\(self.Saturation)"
                                    Settings.SetDouble(.ColorControlsSaturation, Saturation)
                                    Updated.toggle()
                                }
                        ), in: 0.0 ... 1.0)
                    }
                }
                Spacer()
                Spacer()
                Divider()
                    .background(Color.black)
                SampleImage(UICommand: $ButtonCommand,
                            Filter: .ColorControls,
                            Updated: $Updated.wrappedValue)
                    .frame(width: 300, height: 300, alignment: .center)
            }
            .padding()
        }
        .onReceive(Changed.$ChangedFilter, perform:
                    {
                        Value in
                        if Value == BuiltInFilters.ColorControls.rawValue
                        {
                            Brightness = Settings.GetDouble(.ColorControlsBrightness).RoundedTo(2)
                            BrightnessString = "\(Brightness)"
                            Contrast = Settings.GetDouble(.ColorControlsContrast).RoundedTo(2)
                            ContrastString = "\(Contrast)"
                            Saturation = Settings.GetDouble(.ColorControlsSaturation).RoundedTo(2)
                            SaturationString = "\(Saturation)"
                            Updated.toggle()
                        }
                    })
    }
}

struct ColorControlsFilter_Preview: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        ColorControlsFilter_View(ButtonCommand: $NotUsed)
            .environmentObject(ChangedSettings())
    }
}
