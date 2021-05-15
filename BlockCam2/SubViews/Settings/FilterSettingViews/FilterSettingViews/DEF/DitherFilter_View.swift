//
//  DitherFilter_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/8/21.
//

import Foundation
import SwiftUI

struct DitherFilter_View: View
{
    @Binding var ButtonCommand: String
    @EnvironmentObject var Changed: ChangedSettings
    @State var CurrentIntensity: String = "\(Settings.GetDouble(.DitherIntensity, 0.0).RoundedTo(2))"
    @State var ActualIntensity: Double = Settings.GetDouble(.DitherIntensity, 0.0).RoundedTo(2)
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
                            Text("Enter the dithering intensity level")
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
                                                ActualIntensity = Actual.RoundedTo(3)
                                                Settings.SetDouble(.DitherIntensity, ActualIntensity)
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
                                        self.ActualIntensity = newValue.RoundedTo(3)
                                        CurrentIntensity = "\(self.ActualIntensity)"
                                        Settings.SetDouble(.DitherIntensity, self.ActualIntensity)
                                        Updated.toggle()
                                    }
                            ), in: 0 ... 100)
                            .frame(width: Geometry.size.width * 0.3)
                        }
                    }
                    Spacer()
                    Spacer()
                    Divider()
                        .background(Color.black)
                    SampleImage(UICommand: $ButtonCommand,
                                Filter: .Dither,
                                Updated: $Updated.wrappedValue)
                        .frame(width: 300, height: 300, alignment: .center)
                }
            }
            .onReceive(Changed.$ChangedFilter, perform:
                        {
                            Value in
                            if Value == BuiltInFilters.Dither.rawValue
                            {
                                ActualIntensity = Settings.GetDouble(.DitherIntensity, 0.0).RoundedTo(2)
                                CurrentIntensity = "\(ActualIntensity)"
                                Updated.toggle()
                            }
                        })
        }
    }
}

struct DitherFilter_Preview: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        DitherFilter_View(ButtonCommand: $NotUsed)
            .environmentObject(ChangedSettings())
    }
}
