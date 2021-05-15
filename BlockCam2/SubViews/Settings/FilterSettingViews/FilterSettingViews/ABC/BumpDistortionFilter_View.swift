//
//  BumpDistortionFilter_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/6/21.
//

import Foundation
import SwiftUI

struct BumpDistorionFilter_View: View
{
    @EnvironmentObject var Changed: ChangedSettings
    @Binding var ButtonCommand: String
    @State var Updated: Bool = false
    @State var Radius: Double = Settings.GetDouble(.BumpDistortionRadius, 200.0).RoundedTo(2)
    @State var RadiusString: String = "\(Settings.GetDouble(.BumpDistortionRadius, 200.0).RoundedTo(2))"
    @State var Scale: Double = Settings.GetDouble(.BumpDistortionScale, 5.0).RoundedTo(2)
    @State var ScaleString: String = "\(Settings.GetDouble(.BumpDistortionScale, 5.0).RoundedTo(2))"
    
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
                        Text("Radius")
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                        Text("Radial value of the distortion.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                    }
                    .padding()
                    Spacer()
                    VStack
                    {
                        TextField("", text: $RadiusString,
                                  onCommit:
                                    {
                                        if let Actual = Double(self.RadiusString)
                                        {
                                            Radius = Actual.RoundedTo(2)
                                            Settings.SetDouble(.BumpDistortionRadius, Radius)
                                            Updated.toggle()
                                        }
                                    })
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.custom("Avenir-Black", size: 18.0))
                            .keyboardType(.numbersAndPunctuation)
                        
                        Slider(value: Binding(
                                get:
                                    {
                                        self.Radius
                                    },
                                set:
                                    {
                                        (NewValue) in
                                        self.Radius = NewValue
                                        RadiusString = "\(Double(Int(self.Radius)))"
                                        Settings.SetDouble(.BumpDistortionRadius, Double(Int(self.Radius)))
                                        Updated.toggle()
                                    }), in: 0.0 ... 4096.0)
                        
                    }
                }
                Spacer()
                HStack
                {
                    VStack(alignment: .leading)
                    {
                        Text("Scale")
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                        Text("Scale of the distortion.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                    }
                    .padding()
                    Spacer()
                    VStack
                    {
                        TextField("", text: $ScaleString,
                                  onCommit:
                                    {
                                        if let Actual = Double(self.ScaleString)
                                        {
                                            Scale = Actual
                                            Settings.SetDouble(.BumpDistortionScale, Scale.RoundedTo(2))
                                            Updated.toggle()
                                        }
                                    })
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.custom("Avenir-Black", size: 18.0))
                            .keyboardType(.numbersAndPunctuation)
                        
                        Slider(value: Binding(
                                get:
                                    {
                                        self.Scale
                                    },
                                set:
                                    {
                                        (NewValue) in
                                        self.Scale = NewValue
                                        ScaleString = "\(Scale.RoundedTo(2))"
                                        Settings.SetDouble(.BumpDistortionScale, self.Scale.RoundedTo(2))
                                        Updated.toggle()
                                    }), in: -10.0 ... 10.0)
                    }
                }
                Spacer()
                Spacer()
                Divider()
                    .background(Color.black)
                SampleImage(UICommand: $ButtonCommand,
                            Filter: .BumpDistortion,
                            Updated: $Updated.wrappedValue)
                    .frame(width: 300, height: 300, alignment: .center)
            }
            .padding()
        }
        .onReceive(Changed.$ChangedFilter, perform:
                    {
                        Value in
                        if Value == BuiltInFilters.BumpDistortion.rawValue
                        {
                            Radius = Settings.GetDouble(.BumpDistortionRadius, 200.0).RoundedTo(2)
                            RadiusString = "\(Radius)"
                            Scale = Settings.GetDouble(.BumpDistortionScale, 5.0).RoundedTo(2)
                            ScaleString = "\(Scale)"
                            Updated.toggle()
                        }
                    })
    }
}

struct BumpDistorionFilter_Preview: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        BumpDistorionFilter_View(ButtonCommand: $NotUsed)
            .environmentObject(ChangedSettings())
    }
}
