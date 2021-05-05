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
    @State var Options: [FilterOptions: Any] = [.Angle: Settings.GetDouble(.HueAngle, 0.0)]
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
                                                Options[.Angle] = Actual
                                            }
                                        })
                                .padding()
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
                                            self.ActualAngle = newValue
                                            CurrentAngle = "\(Int(self.ActualAngle))"
                                            Settings.SetDouble(.HueAngle, Double(Int(self.ActualAngle)))
                                            Updated.toggle()
                                        }
                            ), in: 0 ... 359)
                            .frame(width: Geometry.size.width * 0.3)
                        }
                    }
                    Spacer()
                    Spacer()
                    #if true
                    SampleImage(Filter: .HueAdjust, Updated: $Updated.wrappedValue)
                        .frame(width: 300, height: 300, alignment: .center)
                    #else
                    SampleImage(FilterOptions: $Options, Filter: .HueAdjust)
                        .frame(width: 300, height: 300, alignment: .center)
                    #endif
                }
            }
        }
    }
}

struct HueAdjustFilter_Preview: PreviewProvider
{
    static var previews: some View
    {
        HueAdjustFilter_View()
    }
}
