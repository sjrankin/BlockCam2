//
//  EdgeWorkFilter_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/10/21.
//

import Foundation
import SwiftUI

struct EdgeWorkFilter_View: View
{
    @Binding var ButtonCommand: String
    @EnvironmentObject var Changed: ChangedSettings
    @State var CurrentThickness: String = "\(Settings.GetDouble(.EdgeWorkThickness, 0.0).RoundedTo(2))"
    @State var ActualThickness: Double = Settings.GetDouble(.EdgeWorkThickness, 0.0).RoundedTo(2)
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
                            Text("Thickness")
                                .frame(width: Geometry.size.width * 0.5,
                                       alignment: .leading)
                            Text("Edge thickness")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(width: Geometry.size.width * 0.5,
                                       alignment: .leading)
                        }
                        .padding()
                        
                        Spacer()
                        
                        VStack
                        {
                            TextField("0.0", text: $CurrentThickness,
                                      onCommit:
                                        {
                                            if let Actual = Double(self.CurrentThickness)
                                            {
                                                ActualThickness = Actual.RoundedTo(2)
                                                Settings.SetDouble(.EdgeWorkThickness, ActualThickness)
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
                                        self.ActualThickness
                                    },
                                set:
                                    {
                                        (newValue) in
                                        self.ActualThickness = newValue.RoundedTo(2)
                                        CurrentThickness = "\(self.ActualThickness)"
                                        Settings.SetDouble(.EdgeWorkThickness, self.ActualThickness)
                                        Updated.toggle()
                                    }
                            ), in: 0 ... 10.0)
                            .frame(width: Geometry.size.width * 0.3)
                        }
                    }
                    .padding()
                    
                    Spacer()
                    Spacer()
                    SampleImage(UICommand: $ButtonCommand,
                                Filter: .EdgeWork,
                                Updated: $Updated.wrappedValue)
                        .frame(width: 300, height: 300, alignment: .center)
                }
            }
        }
        .onReceive(Changed.$ChangedFilter, perform:
                    {
                        Value in
                        if Value == BuiltInFilters.EdgeWork.rawValue
                        {
                            ActualThickness = Settings.GetDouble(.EdgeWorkThickness, 0.1).RoundedTo(2)
                            CurrentThickness = "\(ActualThickness)"
                            Updated.toggle()
                        }
                    })
    }
}

struct EdgeWorkFilter_Preview: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        EdgeWorkFilter_View(ButtonCommand: $NotUsed)
            .environmentObject(ChangedSettings())
    }
}
