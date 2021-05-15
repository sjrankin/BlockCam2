//
//  TwirlDistortionFilter_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/10/21.
//

import Foundation
import SwiftUI

struct TwirlDistortionFilter_View: View
{
    @Binding var ButtonCommand: String
    @EnvironmentObject var Changed: ChangedSettings
    @State var Updated: Bool = false
    @State var Radius: Double = Settings.GetDouble(.TwirlRadius, 100.0).RoundedTo(2)
    @State var RadiusString: String = "\(Settings.GetDouble(.TwirlRadius, 100.0).RoundedTo(2))"
    @State var Angle: Double = Settings.GetDouble(.TwirlAngle, 0.0).RoundedTo(2)
    @State var AngleString: String = "\(Settings.GetDouble(.TwirlAngle, 0.0).RoundedTo(2))"
    
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
                        Text("Twirl radius.")
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
                                            Settings.SetDouble(.TwirlRadius, Radius)
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
                                        self.Radius = NewValue.RoundedTo(2)
                                        RadiusString = "\(self.Radius)"
                                        Settings.SetDouble(.TwirlRadius, self.Radius)
                                        Updated.toggle()
                                    }), in: 0.0 ... 2048.0)
                        
                    }
                }
                HStack
                {
                    VStack(alignment: .leading)
                    {
                        Text("Angle")
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                        Text("Angle of the twirl distortion.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                    }
                    .padding()
                    Spacer()
                    VStack
                    {
                        TextField("", text: $AngleString,
                                  onCommit:
                                    {
                                        if let Actual = Double(self.AngleString)
                                        {
                                            Angle = Actual
                                            Settings.SetDouble(.TwirlAngle, Angle.RoundedTo(2))
                                            Updated.toggle()
                                        }
                                    })
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.custom("Avenir-Black", size: 18.0))
                            .keyboardType(.numbersAndPunctuation)
                        
                        Slider(value: Binding(
                                get:
                                    {
                                        self.Angle
                                    },
                                set:
                                    {
                                        (NewValue) in
                                        self.Angle = NewValue
                                        AngleString = "\(Angle.RoundedTo(2))"
                                        Settings.SetDouble(.TwirlAngle, self.Angle.RoundedTo(2))
                                        Updated.toggle()
                                    }), in: 0.0 ... 359.0)
                    }
                }
                Spacer()
                Spacer()
                Divider()
                    .background(Color.black)
                SampleImage(UICommand: $ButtonCommand,
                            Filter: .TwirlDistortion,
                            Updated: $Updated.wrappedValue)
                    .frame(width: 300, height: 300, alignment: .center)
            }
            .padding()
        }
        .onReceive(Changed.$ChangedFilter, perform:
                    {
                        Value in
                        if Value == BuiltInFilters.TwirlDistortion.rawValue
                        {
                            Radius = Settings.GetDouble(.TwirlRadius, 100.0).RoundedTo(2)
                            RadiusString = "\(Radius)"
                            Angle = Settings.GetDouble(.TwirlAngle, 0.0).RoundedTo(2)
                            AngleString = "\(Angle)"
                            Updated.toggle()
                        }
                    })
    }
}

struct TwirlDistortionFilter_Preview: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        TwirlDistortionFilter_View(ButtonCommand: $NotUsed)
            .environmentObject(ChangedSettings())
    }
}
