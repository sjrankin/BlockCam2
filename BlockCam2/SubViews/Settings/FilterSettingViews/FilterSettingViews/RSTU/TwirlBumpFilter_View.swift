//
//  TwirlBumpFilter_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/24/21.
//

import Foundation
import SwiftUI

struct TwirlBumpFilter_View: View
{
    @Binding var ButtonCommand: String
    @EnvironmentObject var Changed: ChangedSettings
    @State var Updated: Bool = false
    @State var Radius: Double = Settings.GetDouble(.TwirlBumpTwirlRadius, 100.0).RoundedTo(2)
    @State var RadiusString: String = "\(Settings.GetDouble(.TwirlBumpTwirlRadius, 100.0).RoundedTo(2))"
    @State var BumpRadius: Double = Settings.GetDouble(.TwirlBumpBumpRadius, 100.0).RoundedTo(2)
    @State var BumpRadiusString: String = "\(Settings.GetDouble(.TwirlBumpBumpRadius, 100.0).RoundedTo(2))"
    @State var Angle: Double = Settings.GetDouble(.TwirlBumpAngle, 0.0).RoundedTo(2)
    @State var AngleString: String = "\(Settings.GetDouble(.TwirlBumpAngle, 0.0).RoundedTo(2))"
    
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
                        Text("Twirl radius")
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                        Text("Radius of the twirl effect.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                    }
                    .padding()
                    
                    VStack
                    {
                        /*
                        TextField("", text: $RadiusString,
                                  onCommit:
                                    {
                                        if let Actual = Double(self.RadiusString)
                                        {
                                            Radius = Actual.RoundedTo(2)
                                            Settings.SetDouble(.TwirlBumpTwirlRadius, Radius)
                                            Updated.toggle()
                                        }
                                    })
                            .textFieldStyle(RoundedBorderTextFieldStyle())
 */
                            Text(RadiusString)
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
                                        Settings.SetDouble(.TwirlBumpTwirlRadius, self.Radius)
                                        Updated.toggle()
                                    }), in: 0.0 ... 2048.0)
                        
                    }
                }
                
                Divider()
                    .background(Color.black)
                
                HStack
                {
                    VStack(alignment: .leading)
                    {
                        Text("Bump radius")
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                        Text("Radius of the bump effect.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                    }
                    .padding()
                    
                    VStack
                    {
                        /*
                        TextField("", text: $BumpRadiusString,
                                  onCommit:
                                    {
                                        if let Actual = Double(self.BumpRadiusString)
                                        {
                                            BumpRadius = Actual.RoundedTo(2)
                                            Settings.SetDouble(.TwirlBumpBumpRadius, BumpRadius)
                                            Updated.toggle()
                                        }
                                    })
                            .textFieldStyle(RoundedBorderTextFieldStyle())
 */
                        Text(BumpRadiusString)
                            .font(.custom("Avenir-Black", size: 18.0))
                            .keyboardType(.numbersAndPunctuation)
                        
                        Slider(value: Binding(
                                get:
                                    {
                                        self.BumpRadius
                                    },
                                set:
                                    {
                                        (NewValue) in
                                        self.BumpRadius = NewValue.RoundedTo(2)
                                        BumpRadiusString = "\(self.BumpRadius)"
                                        Settings.SetDouble(.TwirlBumpBumpRadius, self.BumpRadius)
                                        Updated.toggle()
                                    }), in: 0.0 ... 2048.0)
                        
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
                        /*
                        TextField("", text: $AngleString,
                                  onCommit:
                                    {
                                        if let Actual = Double(self.AngleString)
                                        {
                                            Angle = Actual
                                            Settings.SetDouble(.TwirlBumpAngle, Angle.RoundedTo(2))
                                            Updated.toggle()
                                        }
                                    })
                            .textFieldStyle(RoundedBorderTextFieldStyle())
 */
                        Text("\(AngleString)°")
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
                                        AngleString = "\(Angle.RoundedTo(0))"
                                        Settings.SetDouble(.TwirlBumpAngle, self.Angle.RoundedTo(2))
                                        Updated.toggle()
                                    }), in: 0.0 ... 359.0)
                    }
                }
                Spacer()
                Divider()
                    .background(Color.black)
                SampleImage(UICommand: $ButtonCommand,
                            Filter: .TwirlBump,
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
                            Radius = Settings.GetDouble(.TwirlBumpTwirlRadius, 100.0).RoundedTo(2)
                            RadiusString = "\(Radius)"
                            BumpRadius = Settings.GetDouble(.TwirlBumpBumpRadius, 100.0).RoundedTo(2)
                            BumpRadiusString = "\(BumpRadius)"
                            Angle = Settings.GetDouble(.TwirlBumpAngle, 0.0).RoundedTo(2)
                            AngleString = "\(Angle)"
                            Updated.toggle()
                        }
                    })
    }
}

struct TwirlBumpFilter_Preview: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        TwirlBumpFilter_View(ButtonCommand: $NotUsed)
            .environmentObject(ChangedSettings())
    }
}
