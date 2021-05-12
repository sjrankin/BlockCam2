//
//  SepiaFilter_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/10/21.
//

import Foundation
import SwiftUI

struct SepiaFilter_View: View
{
    @Binding var ButtonCommand: String
    @EnvironmentObject var Changed: ChangedSettings
    @State var CurrentIntensity: String = "\(Settings.GetDouble(.SepiaIntensity, 0.0).RoundedTo(2))"
    @State var ActualIntensity: Double = Settings.GetDouble(.SepiaIntensity, 0.0).RoundedTo(2)
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
                            Text("Intensity")
                                .frame(width: Geometry.size.width * 0.5,
                                       alignment: .leading)
                            Text("Enter the intensity of the sepia effect")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(width: Geometry.size.width * 0.5,
                                       alignment: .leading)
                        }
                        .padding()
                        
                        Spacer()
                        
                        VStack
                        {
                            TextField("0.0", text: $CurrentIntensity,
                                      onCommit:
                                        {
                                            if let Actual = Double(self.CurrentIntensity)
                                            {
                                                ActualIntensity = Actual.RoundedTo(2)
                                                Settings.SetDouble(.SepiaIntensity, ActualIntensity)
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
                                        self.ActualIntensity
                                    },
                                set:
                                    {
                                        (newValue) in
                                        self.ActualIntensity = newValue.RoundedTo(2)
                                        CurrentIntensity = "\(self.ActualIntensity)"
                                        Settings.SetDouble(.SepiaIntensity, self.ActualIntensity)
                                        Updated.toggle()
                                    }
                            ), in: 0 ... 2.0)
                            .frame(width: Geometry.size.width * 0.3)
                        }
                    }
                    Spacer()
                    Spacer()
                    SampleImage(UICommand: $ButtonCommand,
                                Filter: .Sepia,
                                Updated: $Updated.wrappedValue)
                        .frame(width: 300, height: 300, alignment: .center)
                }
            }
        }
        .onReceive(Changed.$ChangedFilter, perform:
                    {
                        Value in
                        if Value == BuiltInFilters.Sepia.rawValue
                        {
                            ActualIntensity = Settings.GetDouble(.SepiaIntensity, 0.0).RoundedTo(2)
                            CurrentIntensity = "\(ActualIntensity)"
                            Updated.toggle()
                        }
                    })
    }
}

struct SepiaFilter_Preview: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        SepiaFilter_View(ButtonCommand: $NotUsed)
            .environmentObject(ChangedSettings())
    }
}
