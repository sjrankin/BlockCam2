//
//  TriangleKaleidoscopeFilter_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/30/21.
//

import Foundation
import SwiftUI

struct TriangleKaleidoscopeFilter_View: View
{
    @Binding var ButtonCommand: String
    @EnvironmentObject var Changed: ChangedSettings
    @State var Updated: Bool = false
    @State var CurrentSize: String = "\(Settings.GetDouble(.Kaleidoscope3Size).RoundedTo(1))"
    @State var ActualSize: Double = Settings.GetDouble(.Kaleidoscope3Size).RoundedTo(1)
    @State var CurrentAngle: String = "\(Settings.GetDouble(.Kaleidoscope3Rotation).RoundedTo(1))"
    @State var ActualAngle: Double = Settings.GetDouble(.Kaleidoscope3Rotation).RoundedTo(1)
    @State var CurrentFade: String = "\(Settings.GetDouble(.Kaleidoscope3Decay, 0.0).RoundedTo(2))"
    @State var ActualFade: Double = Double(Settings.GetDouble(.Kaleidoscope3Decay, 0.0).RoundedTo(2))
    
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
                            Text("Size")
                                .frame(width: Geometry.size.width * 0.5,
                                       alignment: .leading)
                            Text("Size of the triangle")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(width: Geometry.size.width * 0.5,
                                       alignment: .leading)
                        }
                        .padding()
                        
                        Spacer()
                        
                        VStack
                        {
                            TextField("0", text: $CurrentSize,
                                      onCommit:
                                        {
                                            if let Actual = Double(self.CurrentSize)
                                            {
                                                ActualSize = Actual
                                                Settings.SetDouble(.Kaleidoscope3Size, ActualSize)
                                                self.Updated.toggle()
                                            }
                                        })
                                .padding()
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.custom("Avenir-Black", size: 18.0))
                                .keyboardType(.numbersAndPunctuation)
                            Slider(value: Binding(
                                get:
                                    {
                                    self.ActualSize
                                    },
                                set:
                                    {
                                        (NewValue) in
                                        self.ActualSize = NewValue.RoundedTo(1)
                                        self.CurrentSize = "\(ActualSize)"
                                        Settings.SetDouble(.Kaleidoscope3Size, self.ActualSize)
                                        self.Updated.toggle()
                                    }
                            ), in: 0.0 ... 500.0)
                            .frame(width: Geometry.size.width * 0.3)
                        }
                    }
                    .padding()
                    
                    HStack
                    {
                        VStack(alignment: .leading)
                        {
                            Text("Rotation angle")
                                .frame(width: Geometry.size.width * 0.5,
                                       alignment: .leading)
                            Text("Enter the rotation angle in degrees")
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
                                                ActualAngle = Actual.RoundedTo(1)
                                                Settings.SetDouble(.Kaleidoscope3Rotation, ActualAngle)
                                                Updated.toggle()
                                            }
                                        })
                                .padding()
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.custom("Avenir-Black", size: 18.0))
                                .keyboardType(.numbersAndPunctuation)
                            Slider(value: Binding(
                                get:
                                    {
                                        self.ActualAngle
                                    },
                                set:
                                    {
                                        (NewValue) in
                                        self.ActualAngle = NewValue.RoundedTo(1)
                                        self.CurrentAngle = "\(self.ActualAngle)"
                                        Settings.SetDouble(.Kaleidoscope3Rotation, self.ActualAngle)
                                        self.Updated.toggle()
                                    }
                            ), in: 0.0 ... 359.0)
                            .frame(width: Geometry.size.width * 0.3)
                        }
                    }
                    .padding()
                    
                    HStack
                    {
                        VStack(alignment: .leading)
                        {
                            Text("Color decay")
                                .frame(width: Geometry.size.width * 0.5,
                                       alignment: .leading)
                            Text("Color fading from center to edge of triangle")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(width: Geometry.size.width * 0.5,
                                       alignment: .leading)
                        }
                        .padding()
                        
                        Spacer()
                        
                        VStack
                        {
                            TextField("0.0", text: $CurrentFade,
                                      onCommit:
                                        {
                                            if let Actual = Double(self.CurrentFade)
                                            {
                                                ActualFade = Double(Actual)
                                                Settings.SetDouble(.Kaleidoscope3Decay, Actual)
                                                Updated.toggle()
                                            }
                                        })
                                .padding()
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.custom("Avenir-Black", size: 18.0))
                                .keyboardType(.numbersAndPunctuation)
                            Slider(value: Binding(
                                get:
                                    {
                                        self.ActualFade.RoundedTo(2)
                                    },
                                set:
                                    {
                                        (NewValue) in
                                        self.ActualFade = NewValue.RoundedTo(2)
                                        CurrentFade = "\(self.ActualFade)"
                                        Settings.SetDouble(.Kaleidoscope3Decay, self.ActualFade)
                                        self.Updated.toggle()
                                    }
                            ), in: 0.0 ... 2.0)
                        }
                    }
                    .padding()
                    
                    Spacer()
                    Spacer()
                    SampleImage(UICommand: $ButtonCommand,
                                Filter: .TriangleKaleidoscope,
                                Updated: $Updated.wrappedValue)
                        .frame(width: 300, height: 300, alignment: .center)
                }
            }
        }
        .onReceive(Changed.$ChangedFilter, perform:
                    {
                        Value in
                        if Value == BuiltInFilters.TriangleKaleidoscope.rawValue
                        {
                            ActualSize = Settings.GetDouble(.Kaleidoscope3Size).RoundedTo(1)
                            CurrentSize = "\(ActualSize)"
                            ActualAngle = Settings.GetDouble(.Kaleidoscope3Rotation).RoundedTo(1)
                            CurrentAngle = "\(ActualAngle)"
                            ActualFade = Settings.GetDouble(.Kaleidoscope3Decay, 0.0).RoundedTo(2)
                            CurrentFade = "\(ActualFade)"
                            Updated.toggle()
                        }
                    })
    }
}


struct TriangleKaleidoscopeFilter_Preview: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        TriangleKaleidoscopeFilter_View(ButtonCommand: $NotUsed)
            .environmentObject(ChangedSettings())
    }
}
