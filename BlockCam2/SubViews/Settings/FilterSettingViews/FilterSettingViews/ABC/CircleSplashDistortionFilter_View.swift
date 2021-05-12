//
//  CircleSplashDistortionFilter_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/7/21.
//

import Foundation
import SwiftUI

struct CircleSplashDistortionFilter_View: View
{
    @EnvironmentObject var Changed: ChangedSettings
    @Binding var ButtonCommand: String
    @State var Updated: Bool = false
    @State var Radius: Double = Settings.GetDouble(.CircleSplashDistortionRadius).RoundedTo(2)
    @State var RadiusString: String = "\(Settings.GetDouble(.CircleSplashDistortionRadius, 1.0).RoundedTo(2))"
    
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
                        Text("Radial value of the circle distortion.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                    }
                    .padding()
                    Spacer()
                    TextField("", text: $RadiusString,
                              onCommit:
                                {
                                    if let Actual = Double(self.RadiusString)
                                    {
                                        Radius = Actual
                                        Settings.SetDouble(.CircleSplashDistortionRadius, Radius)
                                        Updated.toggle()
                                    }
                                })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.custom("Avenir-Black", size: 18.0))
                        .keyboardType(.numbersAndPunctuation)
                }
                Spacer()
                Spacer()
                SampleImage(UICommand: $ButtonCommand,
                            Filter: .CircleSplashDistortion,
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
                            Radius = Settings.GetDouble(.CircleSplashDistortionRadius).RoundedTo(2)
                            RadiusString = "\(Radius)"
                            Updated.toggle()
                        }
                    })
    }
}

struct CircleSplashDistortionFilter_Preview: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        CircleSplashDistortionFilter_View(ButtonCommand: $NotUsed)
            .environmentObject(ChangedSettings())
    }
}
