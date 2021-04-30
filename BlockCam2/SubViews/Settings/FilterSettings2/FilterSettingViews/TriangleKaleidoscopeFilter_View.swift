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
    @State var CurrentAngle: String = "\(Settings.GetInt(.Kaleidoscope3Rotation))"
    @State var ActualAngle: Double = Double(Settings.GetInt(.Kaleidoscope3Rotation))
    @State var CurrentFade: String = "\(Settings.GetDouble(.Kaleidoscope3Decay, 0.0))"
    @State var ActualFade: Double = Double(Settings.GetDouble(.Kaleidoscope3Decay, 0.0))
    
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
                            Text("Rotation angle")
                            Text("Enter the rotation angle in degrees")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(width: Geometry.size.width * 0.6)
                        
                        Spacer()
                        
                        VStack
                        {
                            TextField("0.0", text: $CurrentAngle,
                                      onCommit:
                                        {
                                            if let Actual = Double(self.CurrentAngle)
                                            {
                                                ActualAngle = Double(Int(Actual))
                                                Settings.SetInt(.Kaleidoscope3Rotation, Int(Actual))
                                            }
                                        })
                                .padding()
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.custom("Avenir-Black", size: 18.0))
                                .frame(width: Geometry.size.width * 0.35)
                                .keyboardType(.numbersAndPunctuation)
                            
                            Slider(value: $ActualAngle, in: 0 ... 359,
                                   onEditingChanged:
                                    {
                                        Editing in
                                        if !Editing
                                        {
                                            CurrentAngle = "\(Int(ActualAngle))"
                                            Settings.SetInt(.Kaleidoscope3Rotation, Int(ActualAngle))
                                        }
                                    })
                                .frame(width: Geometry.size.width * 0.30)
                        }
                    }
                    
                    HStack
                    {
                        VStack(alignment: .leading)
                        {
                            Text("Color decay")
                            Text("Color fading from center to edge of triangle")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(width: Geometry.size.width * 0.6)
                        
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
                                            }
                                        })
                                .padding()
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.custom("Avenir-Black", size: 18.0))
                                .frame(width: Geometry.size.width * 0.35)
                                .keyboardType(.numbersAndPunctuation)
                            
                            Slider(value: $ActualFade, in: 0 ... 359,
                                   onEditingChanged:
                                    {
                                        Editing in
                                        if !Editing
                                        {
                                            CurrentFade = "\(ActualFade)"
                                            Settings.SetDouble(.Kaleidoscope3Decay, ActualAngle)
                                        }
                                    })
                                .frame(width: Geometry.size.width * 0.30)
                        }
                    }
                }
            }
        }
    }
}
