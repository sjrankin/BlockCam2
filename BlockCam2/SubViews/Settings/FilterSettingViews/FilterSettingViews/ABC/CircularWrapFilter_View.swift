//
//  CircularWrapFilter_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/27/21.
//

import Foundation
import SwiftUI

struct CircularWrapFilter_View: View
{
    @EnvironmentObject var Changed: ChangedSettings
    @Binding var ButtonCommand: String
    @State var Updated: Bool = false
    @State var Angle: Double = Settings.GetDouble(.CircularWrapAngle).RoundedTo(1)
    @State var AngleString: String = Settings.GetDouble(.CircularWrapAngle).RoundedTo(1, PadTo: 1)
    @State var Radius: Double = Settings.GetDouble(.CircularWrapRadius).RoundedTo(2)
    @State var RadiusString: String = "\(Settings.GetDouble(.CircularWrapRadius, 1.0).RoundedTo(2))"
    
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
                        Text("Radial value of the wrap.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                    }
                    .padding()
                    
                    VStack(alignment: .trailing)
                    {
                        Text($RadiusString.wrappedValue)
                            .font(Font.system(.body, design: .monospaced).monospacedDigit())
                            .font(.custom("Avenir-Black", size: 18.0))
                            .frame(alignment: .trailing)
                        Slider(value: Binding(
                            get:
                                {
                                    self.Radius
                                },
                            set:
                                {
                                    NewValue in
                                    self.Radius = NewValue.RoundedTo(1)
                                    self.RadiusString = NewValue.RoundedTo(1, PadTo: 1)
                                    Settings.SetDouble(.CircularWrapRadius, self.Radius)
                                    Updated.toggle()
                                }
                        ), in: 0.0 ... 500.0
                        )
                    }
                }
                
                Divider()
                    .background(Color.black)
                
                HStack
                {
                    VStack(alignment: .leading)
                    {
                        Text("Angle")
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                        Text("Radial angle of the wrap.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                    }
                    .padding()
                    
                    VStack(alignment: .trailing)
                    {
                        Text($AngleString.wrappedValue + "°")
                            .font(Font.system(.body, design: .monospaced).monospacedDigit())
                            .font(.custom("Avenir-Black", size: 18.0))
                            .frame(alignment: .trailing)
                        Slider(value: Binding(
                            get:
                                {
                                    self.Angle
                                },
                            set:
                                {
                                    NewValue in
                                    self.Angle = NewValue.RoundedTo(1)
                                    self.AngleString = NewValue.RoundedTo(1, PadTo: 1)
                                    Settings.SetDouble(.CircularWrapAngle, self.Angle)
                                    Updated.toggle()
                                }
                        ), in: 0.0 ... 359.0
                        )
                    }
                }
                Spacer()
                Divider()
                    .background(Color.black)
                SampleImage(UICommand: $ButtonCommand,
                            Filter: .CircularWrap,
                            Updated: $Updated.wrappedValue)
                    .frame(width: 300, height: 300, alignment: .center)
            }
            .padding()
        }
        .onReceive(Changed.$ChangedFilter, perform:
                    {
                        Value in
                        if Value == BuiltInFilters.CircleSplashDistortion.rawValue
                        {
                            Radius = Settings.GetDouble(.CircularWrapRadius).RoundedTo(2)
                            RadiusString = "\(Radius)"
                            Angle = Settings.GetDouble(.CircularWrapAngle).RoundedTo(1)
                            AngleString = Settings.GetDouble(.CircularWrapAngle).RoundedTo(1, PadTo: 1)
                            Updated.toggle()
                        }
                    })
    }
}

struct CircularWrapFilter_Preview: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        CircularWrapFilter_View(ButtonCommand: $NotUsed)
            .environmentObject(ChangedSettings())
    }
}
