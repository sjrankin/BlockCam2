//
//  VibranceFilter_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/8/21.
//

import Foundation
import SwiftUI

struct VibranceFilter_View: View
{
    @Binding var ButtonCommand: String
    @EnvironmentObject var Changed: ChangedSettings
    @State var CurrentVibrance: String = "\(Settings.GetDouble(.VibranceAmount, 0.0).RoundedTo(2))"
    @State var ActualVibrance: Double = Settings.GetDouble(.VibranceAmount, 0.0).RoundedTo(2)
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
                            Text("Amount")
                                .frame(width: Geometry.size.width * 0.5,
                                       alignment: .leading)
                            Text("Enter the vibrance amount")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(width: Geometry.size.width * 0.5,
                                       alignment: .leading)
                        }
                        .padding()
                        
                        Spacer()
                        
                        VStack
                        {
                            TextField("0.0", text: $CurrentVibrance,
                                      onCommit:
                                        {
                                            if let Actual = Double(self.CurrentVibrance)
                                            {
                                                ActualVibrance = Actual.RoundedTo(2)
                                                Settings.SetDouble(.VibranceAmount, Actual)
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
                                        self.ActualVibrance
                                    },
                                set:
                                    {
                                        (newValue) in
                                        self.ActualVibrance = newValue.RoundedTo(2)
                                        CurrentVibrance = "\(self.ActualVibrance)"
                                        Settings.SetDouble(.VibranceAmount, self.ActualVibrance)
                                        Updated.toggle()
                                    }
                            ), in: 0 ... 50)
                            .frame(width: Geometry.size.width * 0.3)
                        }
                    }
                    Spacer()
                    Spacer()
                    Divider()
                        .background(Color.black)
                    SampleImage(UICommand: $ButtonCommand,
                                Filter: .Vibrance,
                                Updated: $Updated.wrappedValue)
                        .frame(width: 300, height: 300, alignment: .center)
                }
            }
        }
        .onReceive(Changed.$ChangedFilter, perform:
                    {
                        Value in
                        if Value == BuiltInFilters.Vibrance.rawValue
                        {
                            ActualVibrance = Settings.GetDouble(.VibranceAmount, 0.0).RoundedTo(2)
                            CurrentVibrance = "\(ActualVibrance)"
                            Updated.toggle()
                        }
                    })
    }
}

struct VibranceFilter_Preview: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        VibranceFilter_View(ButtonCommand: $NotUsed)
            .environmentObject(ChangedSettings())
    }
}
