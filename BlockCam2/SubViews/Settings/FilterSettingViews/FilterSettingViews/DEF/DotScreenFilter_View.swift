//
//  DotScreenFilter_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/8/21.
//

import Foundation
import SwiftUI

struct DotScreenFilter_View: View
{
    @Binding var ButtonCommand: String
    @EnvironmentObject var Changed: ChangedSettings
    @State var CurrentAngle: String = "\(Settings.GetDouble(.DotScreenAngle, 0.0).RoundedTo(2))"
    @State var ActualAngle: Double = Settings.GetDouble(.DotScreenAngle, 0.0).RoundedTo(2)
    @State var CurrentSharpness: String = "\(Settings.GetDouble(.DotScreenSharpness, 0.0).RoundedTo(2))"
    @State var ActualSharpness: Double = Settings.GetDouble(.DotScreenSharpness, 0.0).RoundedTo(2)
    @State var CurrentWidth: String = "\(Settings.GetDouble(.DotScreenWidth, 0.0).RoundedTo(2))"
    @State var ActualWidth: Double = Settings.GetDouble(.DotScreenWidth, 0.0).RoundedTo(2)
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
                            Text("Dot screen angle")
                                .frame(width: Geometry.size.width * 0.5,
                                       alignment: .leading)
                            Text("Enter the dot screen angle in degrees")
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
                                                ActualAngle = Actual.RoundedTo(3)
                                                Settings.SetDouble(.DotScreenAngle, ActualAngle)
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
                                        Settings.SetDouble(.DotScreenAngle, self.ActualAngle)
                                        Updated.toggle()
                                    }
                            ), in: 0 ... 359)
                            .frame(width: Geometry.size.width * 0.3)
                        }
                    }
                    
                    HStack
                    {
                        VStack(alignment: .leading)
                        {
                            Text("Width")
                                .frame(width: Geometry.size.width * 0.5,
                                       alignment: .leading)
                            Text("Enter the width")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(width: Geometry.size.width * 0.5,
                                       alignment: .leading)
                        }
                        .padding()
                        
                        Spacer()
                        
                        VStack
                        {
                            TextField("0.0", text: $CurrentWidth,
                                      onCommit:
                                        {
                                            if let Actual = Double(self.CurrentWidth)
                                            {
                                                ActualWidth = Actual.RoundedTo(3)
                                                Settings.SetDouble(.DotScreenWidth, ActualWidth)
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
                                        self.ActualWidth
                                    },
                                set:
                                    {
                                        (newValue) in
                                        self.ActualWidth = newValue.RoundedTo(3)
                                        CurrentWidth = "\(self.ActualWidth)"
                                        Settings.SetDouble(.DotScreenWidth, self.ActualWidth)
                                        Updated.toggle()
                                    }
                            ), in: 0.5 ... 10.0)
                            .frame(width: Geometry.size.width * 0.3)
                        }
                    }
                    
                    HStack
                    {
                        VStack(alignment: .leading)
                        {
                            Text("Sharpness")
                                .frame(width: Geometry.size.width * 0.5,
                                       alignment: .leading)
                            Text("Enter the sharpness")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(width: Geometry.size.width * 0.5,
                                       alignment: .leading)
                        }
                        .padding()
                        
                        Spacer()
                        
                        VStack
                        {
                            TextField("0.0", text: $CurrentSharpness,
                                      onCommit:
                                        {
                                            if let Actual = Double(self.CurrentSharpness)
                                            {
                                                ActualSharpness = Actual.RoundedTo(3)
                                                Settings.SetDouble(.DotScreenSharpness, ActualSharpness)
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
                                        self.ActualSharpness
                                    },
                                set:
                                    {
                                        (newValue) in
                                        self.ActualSharpness = newValue.RoundedTo(3)
                                        CurrentSharpness = "\(self.ActualSharpness)"
                                        Settings.SetDouble(.DotScreenSharpness, self.ActualSharpness)
                                        Updated.toggle()
                                    }
                            ), in: 0.0 ... 1.0)
                            .frame(width: Geometry.size.width * 0.3)
                        }
                    }
                    Spacer()
                    Spacer()
                    Divider()
                        .background(Color.black)
                    SampleImage(UICommand: $ButtonCommand,
                                Filter: .DotScreen,
                                Updated: $Updated.wrappedValue)
                        .frame(width: 300, height: 300, alignment: .center)
                }
            }
            .onReceive(Changed.$ChangedFilter, perform:
                        {
                            Value in
                            if Value == BuiltInFilters.DotScreen.rawValue
                            {
                                ActualAngle = Settings.GetDouble(.DotScreenAngle, 0.0)
                                CurrentAngle = "\(ActualAngle)"
                                ActualSharpness = Settings.GetDouble(.DotScreenSharpness, 0.0).RoundedTo(2)
                                CurrentSharpness = "\(ActualSharpness)"
                                ActualWidth = Settings.GetDouble(.DotScreenWidth, 0.0).RoundedTo(2)
                                CurrentWidth = "\(ActualWidth)"
                                Updated.toggle()
                            }
                        })
        }
    }
}

struct DotScreenFilter_Preview: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        DotScreenFilter_View(ButtonCommand: $NotUsed)
            .environmentObject(ChangedSettings())
    }
}
