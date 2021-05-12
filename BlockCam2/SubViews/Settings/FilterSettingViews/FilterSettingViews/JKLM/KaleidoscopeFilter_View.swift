//
//  KaleidoscopeFilter_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/30/21.
//

import Foundation
import SwiftUI

struct KaleidoscopeFilter_View: View
{
    @Binding var ButtonCommand: String
    @EnvironmentObject var Changed: ChangedSettings
    @State var Updated: Bool = false
    @State var Angle: Double = Double(Settings.GetInt(.KaleidoscopeAngleOfReflection))
    @State var AngleString: String = "\(Settings.GetInt(.KaleidoscopeAngleOfReflection))"
    @State var SegmentCount: Double = Double(Settings.GetInt(.KaleidoscopeSegmentCount))
    @State var SegmentCountString: String = "\(Settings.GetInt(.KaleidoscopeSegmentCount))"
    @State var ApplyBackground: Bool = Settings.GetBool(.KaleidoscopeFillBackground)
    
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
                        Text("Segments")
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                        Text("Number of segments in the kaleidoscope")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                    }
                    .padding()
                    
                    Spacer()
                    
                    VStack
                    {
                        Slider(value: Binding(
                            get:
                                {
                                    self.SegmentCount
                                },
                            set:
                                {
                                    (NewValue) in
                                    self.SegmentCount = NewValue
                                    self.SegmentCountString = "\(Int(self.SegmentCount))"
                                    Settings.SetInt(.KaleidoscopeSegmentCount, Int(self.SegmentCount))
                                    self.Updated.toggle()
                                }
                        ), in: 2 ... 40)
                        TextField("", text: $SegmentCountString,
                                  onCommit:
                                    {
                                        if let Actual = Int(self.SegmentCountString)
                                        {
                                            Settings.SetInt(.KaleidoscopeSegmentCount, Actual)
                                            SegmentCount = Double(Actual)
                                            Updated.toggle()
                                        }
                                    })
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.custom("Avenir-Black", size: 18.0))
                            .keyboardType(.numbersAndPunctuation)
                    }
                    .padding()
                }
                
                HStack
                {
                    VStack(alignment: .leading)
                    {
                        Text("Angle")
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                        Text("Angle of reflection")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                    }
                    .padding()
                    Spacer()
                    VStack
                    {
                        Slider(value: Binding(
                            get:
                                {
                                    self.Angle
                                },
                            set:
                                {
                                    (NewValue) in
                                    self.Angle = NewValue
                                    self.AngleString = "\(Int(self.Angle))"
                                    Settings.SetInt(.KaleidoscopeAngleOfReflection, Int(self.Angle))
                                    self.Updated.toggle()
                                }
                        ), in: 0 ... 359
                        )
                        TextField("0", text: $AngleString,
                                  onCommit:
                                    {
                                        if let Actual = Int(self.AngleString)
                                        {
                                            Settings.SetInt(.KaleidoscopeAngleOfReflection, Actual)
                                            Angle = Double(Actual)
                                            Updated.toggle()
                                        }
                                    })
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.custom("Avenir-Black", size: 18.0))
                            .keyboardType(.numbersAndPunctuation)
                    }
                    .padding()
                }
                
                HStack
                {
                    VStack(alignment: .leading)
                    {
                        Text("Background")
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                        Text("Apply a black background")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                    }
                    .padding()
                    
                    Toggle(isOn: self.$ApplyBackground)
                    {
                        Text("Enable")
                    }
                    .onReceive([self.ApplyBackground].publisher.first())
                    {
                        Value in
                        Settings.SetBool(.KaleidoscopeFillBackground, Value)
                        Updated.toggle()
                    }
                    .padding()
                }

                Spacer()
                SampleImage(UICommand: $ButtonCommand,
                            Filter: .Kaleidoscope,
                            Updated: $Updated.wrappedValue)
                    .frame(width: 300, height: 300, alignment: .center)
            }
        }
        .onReceive(Changed.$ChangedFilter, perform:
                    {
                        Value in
                        if Value == BuiltInFilters.Kaleidoscope.rawValue
                        {
                            Angle = Double(Settings.GetInt(.KaleidoscopeAngleOfReflection))
                            AngleString = "\(Settings.GetInt(.KaleidoscopeAngleOfReflection))"
                            SegmentCount = Double(Settings.GetInt(.KaleidoscopeSegmentCount))
                            SegmentCountString = "\(Settings.GetInt(.KaleidoscopeSegmentCount))"
                            ApplyBackground = Settings.GetBool(.KaleidoscopeFillBackground)
                            Updated.toggle()
                        }
                    })
    }
}

struct KaleidoscopeFilter_Preview: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        KaleidoscopeFilter_View(ButtonCommand: $NotUsed)
            .environmentObject(ChangedSettings())
    }
}
