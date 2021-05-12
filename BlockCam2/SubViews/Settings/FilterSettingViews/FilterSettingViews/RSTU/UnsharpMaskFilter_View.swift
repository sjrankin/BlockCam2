//
//  UnsharpMaskFilter_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/10/21.
//

import Foundation
import SwiftUI

struct UnsharpMaskFilter_View: View
{
    @Binding var ButtonCommand: String
    @EnvironmentObject var Changed: ChangedSettings
    @State var Updated: Bool = false
    @State var Radius: Double = Settings.GetDouble(.UnsharpRadius, 200.0).RoundedTo(2)
    @State var RadiusString: String = "\(Settings.GetDouble(.UnsharpRadius, 200.0).RoundedTo(2))"
    @State var Intensity: Double = Settings.GetDouble(.UnsharpIntensity, 5.0).RoundedTo(2)
    @State var IntensityString: String = "\(Settings.GetDouble(.UnsharpIntensity, 5.0).RoundedTo(2))"
    
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
                        Text("Pixel radius.")
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
                                            Settings.SetDouble(.UnsharpRadius, Radius)
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
                                        Settings.SetDouble(.UnsharpRadius, self.Radius)
                                        Updated.toggle()
                                    }), in: 0.0 ... 2048.0)
                        
                    }
                }
                HStack
                {
                    VStack(alignment: .leading)
                    {
                        Text("Intensity")
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                        Text("Intensity of the unsharp mask.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                    }
                    .padding()
                    Spacer()
                    VStack
                    {
                        TextField("", text: $IntensityString,
                                  onCommit:
                                    {
                                        if let Actual = Double(self.IntensityString)
                                        {
                                            Intensity = Actual
                                            Settings.SetDouble(.UnsharpIntensity, Intensity.RoundedTo(2))
                                            Updated.toggle()
                                        }
                                    })
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.custom("Avenir-Black", size: 18.0))
                            .keyboardType(.numbersAndPunctuation)
                        
                        Slider(value: Binding(
                                get:
                                    {
                                        self.Intensity
                                    },
                                set:
                                    {
                                        (NewValue) in
                                        self.Intensity = NewValue
                                        IntensityString = "\(Intensity.RoundedTo(2))"
                                        Settings.SetDouble(.UnsharpIntensity, self.Intensity.RoundedTo(2))
                                        Updated.toggle()
                                    }), in: 0.0 ... 10.0)
                    }
                }
                Spacer()
                Spacer()
                SampleImage(UICommand: $ButtonCommand,
                            Filter: .UnsharpMask,
                            Updated: $Updated.wrappedValue)
                    .frame(width: 300, height: 300, alignment: .center)
            }
            .padding()
        }
        .onReceive(Changed.$ChangedFilter, perform:
                    {
                        Value in
                        if Value == BuiltInFilters.UnsharpMask.rawValue
                        {
                            Radius = Settings.GetDouble(.UnsharpRadius, 200.0).RoundedTo(2)
                            RadiusString = "\(Radius)"
                            Intensity = Settings.GetDouble(.UnsharpIntensity, 5.0).RoundedTo(2)
                            IntensityString = "\(Intensity)"
                            Updated.toggle()
                        }
                    })
    }
}

struct UnsharpMaskFilter_Preview: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        UnsharpMaskFilter_View(ButtonCommand: $NotUsed)
            .environmentObject(ChangedSettings())
    }
}
