//
//  ExposureFilter_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/9/21.
//

import Foundation
import SwiftUI

struct ExposureFilter_View: View
{
    @Binding var ButtonCommand: String
    @EnvironmentObject var Changed: ChangedSettings
    @State var CurrentExposure: String = "\(Settings.GetDouble(.ExposureValue, 0.0).RoundedTo(2))"
    @State var ActualExposure: Double = Settings.GetDouble(.ExposureValue, 0.0).RoundedTo(2)
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
                            Text("Exposure")
                                .frame(width: Geometry.size.width * 0.5,
                                       alignment: .leading)
                            Text("Enter the exposure value")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(width: Geometry.size.width * 0.5,
                                       alignment: .leading)
                        }
                        .padding()
                        
                        Spacer()
                        
                        VStack
                        {
                            TextField("0.0", text: $CurrentExposure,
                                      onCommit:
                                        {
                                            if let Actual = Double(self.CurrentExposure)
                                            {
                                                ActualExposure = Actual.RoundedTo(2)
                                                Settings.SetDouble(.ExposureValue, ActualExposure)
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
                                        self.ActualExposure
                                    },
                                set:
                                    {
                                        (newValue) in
                                        self.ActualExposure = newValue.RoundedTo(2)
                                        CurrentExposure = "\(self.ActualExposure)"
                                        Settings.SetDouble(.ExposureValue, self.ActualExposure)
                                        Updated.toggle()
                                    }
                            ), in: 0.0 ... 5.0)
                            .frame(width: Geometry.size.width * 0.3)
                        }
                    }
                    Spacer()
                    Spacer()
                    SampleImage(UICommand: $ButtonCommand,
                                Filter: .ExposureAdjust,
                                Updated: $Updated.wrappedValue)
                        .frame(width: 300, height: 300, alignment: .center)
                }
                .padding()
            }
        }
        .onReceive(Changed.$ChangedFilter, perform:
                    {
                        Value in
                        if Value == BuiltInFilters.ExposureAdjust.rawValue
                        {
                            ActualExposure = Settings.GetDouble(.ExposureValue, 0.0).RoundedTo(2)
                            CurrentExposure = "\(ActualExposure)"
                            Updated.toggle()
                        }
                    })
    }
}

struct ExposureFilter_Preview: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        ExposureFilter_View(ButtonCommand: $NotUsed)
            .environmentObject(ChangedSettings())
    }
}
