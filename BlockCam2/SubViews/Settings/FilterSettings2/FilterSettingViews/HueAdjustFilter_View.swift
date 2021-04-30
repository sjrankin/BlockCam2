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
    @State var CurrentAngle: String = "\(Int(Settings.GetDouble(.HueAngle, 0.0)))"
    @State var ActualAngle: Double = Double(Int(Settings.GetDouble(.HueAngle, 0.0)))
    
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
                            Text("Enter the hue angle in degrees")
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
                                                Settings.SetDouble(.HueAngle, Double(Int(Actual)))
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
                                            Settings.SetDouble(.HueAngle, ActualAngle)
                                        }
                                    })
                                .frame(width: Geometry.size.width * 0.30)
                                .onChange(of: "value")
                                {
                                    value in
                                    if let Actual = Int(value)
                                    {
                                        CurrentAngle = "\(Int(Actual))"
                                    }
                                }
                        }
                    }
                }
            }
        }
    }
}
