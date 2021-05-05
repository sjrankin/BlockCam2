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
    @State var Updated: Bool = false
    @State var CurrentSize: String = "\(Settings.GetInt(.Kaleidoscope3Size))"
    @State var ActualSize: Int = Settings.GetInt(.Kaleidoscope3Size)
    @State var CurrentAngle: String = "\(Settings.GetInt(.Kaleidoscope3Rotation))"
    @State var ActualAngle: Double = Double(Settings.GetInt(.Kaleidoscope3Rotation))
    @State var CurrentFade: String = "\(Settings.GetDouble(.Kaleidoscope3Decay, 0.0))"
    @State var ActualFade: Double = Double(Settings.GetDouble(.Kaleidoscope3Decay, 0.0))
    @State var Options: [FilterOptions: Any] =
        [
            .Decay: Settings.GetDouble(.Kaleidoscope3Decay, 0.0),
         .Rotation: Double(Settings.GetInt(.Kaleidoscope3Rotation)),
            .Size: Settings.GetInt(.Kaleidoscope3Size)
        ]
    
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
                            Text("Size of the triangle")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        
                        Spacer()
                        
                        VStack
                        {
                            TextField("0", text: $CurrentSize,
                                      onCommit:
                                        {
                                            if let Actual = Int(self.CurrentSize)
                                            {
                                                ActualSize = Actual
                                                Settings.SetInt(.Kaleidoscope3Size, ActualSize)
                                                Options[.Size] = ActualSize
                                            }
                                        })
                                .padding()
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.custom("Avenir-Black", size: 18.0))
                                .keyboardType(.numbersAndPunctuation)
                        }
                    }
                    .padding()
                    
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
                                                Options[.Angle] = Actual
                                            }
                                        })
                                .padding()
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.custom("Avenir-Black", size: 18.0))
                                .keyboardType(.numbersAndPunctuation)
                            
                            Slider(value: $ActualAngle, in: 0 ... 359,
                                   onEditingChanged:
                                    {
                                        Editing in
                                        if !Editing
                                        {
                                            CurrentAngle = "\(Int(ActualAngle))"
                                            Settings.SetInt(.Kaleidoscope3Rotation, Int(ActualAngle))
                                            Options[.Angle] = ActualAngle
                                        }
                                    })
                                .frame(width: Geometry.size.width * 0.30)
                        }
                    }
                    .padding()
                    
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
                                                Options[.Decay] = Actual
                                            }
                                        })
                                .padding()
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.custom("Avenir-Black", size: 18.0))
                                .keyboardType(.numbersAndPunctuation)
                            
                            Slider(value: $ActualFade, in: 0 ... 359,
                                   onEditingChanged:
                                    {
                                        Editing in
                                        if !Editing
                                        {
                                            CurrentFade = "\(ActualFade)"
                                            Settings.SetDouble(.Kaleidoscope3Decay, ActualFade)
                                            Options[.Decay] = ActualFade
                                        }
                                    })
                                .frame(width: Geometry.size.width * 0.30)
                        }
                    }
                    .padding()
                    
                    Spacer()
                    Spacer()
                    #if true
                    SampleImage(Filter: .TriangleKaleidoscope, Updated: $Updated.wrappedValue)
                        .frame(width: 300, height: 300, alignment: .center)
                    #else
                    SampleImage(FilterOptions: $Options, Filter: .TriangleKaleidoscope)
                        .frame(width: 300, height: 300, alignment: .center)
                    #endif
                }
            }
        }
    }
}


struct TriangleKaleidoscopeFilter_Preview: PreviewProvider
{
    static var previews: some View
    {
        TriangleKaleidoscopeFilter_View()
    }
}
