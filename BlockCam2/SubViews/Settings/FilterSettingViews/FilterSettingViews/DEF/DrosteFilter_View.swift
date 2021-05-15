//
//  DrosteFilter_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/8/21.
//

import Foundation
import SwiftUI

struct DrosteFilter_View: View
{
    @Binding var ButtonCommand: String
    @EnvironmentObject var Changed: ChangedSettings
    
    @State var CurrentPeriodicity: String = "\(Settings.GetDouble(.DrostePeriodicity, 0.0))"
    @State var ActualPeriodicity: Double = Double(Settings.GetDouble(.DrostePeriodicity, 0.0))
    
    @State var CurrentStrands: String = "\(Settings.GetDouble(.DrosteStrands, 0.0).RoundedTo(1))"
    @State var ActualStrands: Double = Double(Settings.GetDouble(.DrosteStrands, 0.0)).RoundedTo(1)
    
    @State var CurrentRotation: String = "\(Settings.GetDouble(.DrosteRotation, 0.0))"
    @State var ActualRotation: Double = Double(Settings.GetDouble(.DrosteRotation, 0.0))
    
    @State var CurrentZoom: String = "\(Settings.GetDouble(.DrosteZoom, 0.0))"
    @State var ActualZoom: Double = Double(Settings.GetDouble(.DrosteZoom, 0.0))
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
                    // MARK: - Periodicity
                    HStack
                    {
                        VStack(alignment: .leading)
                        {
                            Text("Periodicity")
                                .frame(width: Geometry.size.width * 0.5,
                                       alignment: .leading)
                            Text("Enter the periodicity of the filter")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(width: Geometry.size.width * 0.5,
                                       alignment: .leading)
                        }
                        .padding()
                        
                        Spacer()
                        
                        VStack
                        {
                            TextField("0.0", text: $CurrentPeriodicity,
                                      onCommit:
                                        {
                                            if let Actual = Double(self.CurrentPeriodicity)
                                            {
                                                ActualPeriodicity = Actual.RoundedTo(3)
                                                Settings.SetDouble(.DrostePeriodicity, ActualPeriodicity)
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
                                        self.ActualPeriodicity
                                    },
                                set:
                                    {
                                        (newValue) in
                                        self.ActualPeriodicity = newValue.RoundedTo(3)
                                        CurrentPeriodicity = "\(self.ActualPeriodicity)"
                                        Settings.SetDouble(.DrostePeriodicity, self.ActualPeriodicity)
                                        Updated.toggle()
                                    }
                            ), in: 1.0 ... 20.0)
                            .frame(width: Geometry.size.width * 0.3)
                        }
                    }
                    
                    // MARK: - Rotation
                    HStack
                    {
                        VStack(alignment: .leading)
                        {
                            Text("Rotation")
                                .frame(width: Geometry.size.width * 0.5,
                                       alignment: .leading)
                            Text("Enter the rotation for the filter")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(width: Geometry.size.width * 0.5,
                                       alignment: .leading)
                        }
                        .padding()
                        
                        Spacer()
                        
                        VStack
                        {
                            TextField("0.0", text: $CurrentRotation,
                                      onCommit:
                                        {
                                            if let Actual = Double(self.CurrentRotation)
                                            {
                                                ActualRotation = Actual.RoundedTo(3)
                                                Settings.SetDouble(.DotScreenWidth, ActualRotation)
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
                                        self.ActualRotation
                                    },
                                set:
                                    {
                                        (newValue) in
                                        self.ActualRotation = newValue.RoundedTo(3)
                                        CurrentRotation = "\(self.ActualRotation)"
                                        Settings.SetDouble(.DrosteRotation, self.ActualRotation)
                                        Updated.toggle()
                                    }
                            ), in: 0.0 ... 360.0)
                            .frame(width: Geometry.size.width * 0.3)
                        }
                    }
                    
                    // MARK: - Strands
                    HStack
                    {
                        VStack(alignment: .leading)
                        {
                            Text("Strands")
                                .frame(width: Geometry.size.width * 0.5,
                                       alignment: .leading)
                            Text("Enter the strands for the filter")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(width: Geometry.size.width * 0.5,
                                       alignment: .leading)
                        }
                        .padding()
                        
                        Spacer()
                        
                        VStack
                        {
                            TextField("0.0", text: $CurrentStrands,
                                      onCommit:
                                        {
                                            if let Actual = Double(self.CurrentStrands)
                                            {
                                                ActualStrands = Actual.RoundedTo(1)
                                                Settings.SetDouble(.DrosteStrands, ActualStrands)
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
                                        self.ActualStrands
                                    },
                                set:
                                    {
                                        (newValue) in
                                        self.ActualStrands = newValue.RoundedTo(1)
                                        CurrentStrands = "\(self.ActualStrands)"
                                        Settings.SetDouble(.DrosteStrands, self.ActualStrands)
                                        Updated.toggle()
                                    }
                            ), in: 0.0 ... 10.0)
                            .frame(width: Geometry.size.width * 0.3)
                        }
                    }
                    
                    Spacer()
                    
                    // MARK: - Zoom
                    HStack
                    {
                        VStack(alignment: .leading)
                        {
                            Text("Zoom")
                                .frame(width: Geometry.size.width * 0.5,
                                       alignment: .leading)
                            Text("Zoom level into the image")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(width: Geometry.size.width * 0.5,
                                       alignment: .leading)
                        }
                        .padding()
                        
                        Spacer()
                        
                        VStack
                        {
                            TextField("0.0", text: $CurrentZoom,
                                      onCommit:
                                        {
                                            if let Actual = Double(self.CurrentZoom)
                                            {
                                                ActualZoom = Actual.RoundedTo(1)
                                                Settings.SetDouble(.DrosteZoom, ActualZoom)
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
                                        self.ActualZoom
                                    },
                                set:
                                    {
                                        (newValue) in
                                        self.ActualZoom = newValue.RoundedTo(1)
                                        CurrentZoom = "\(self.ActualZoom)"
                                        Settings.SetDouble(.DrosteZoom, self.ActualZoom)
                                        Updated.toggle()
                                    }
                            ), in: 0.0 ... 50.0)
                            .frame(width: Geometry.size.width * 0.3)
                        }
                    }
                    
                    Spacer()
                    Spacer()
                    Divider()
                        .background(Color.black)
                    SampleImage(UICommand: $ButtonCommand,
                                Filter: .Droste,
                                Updated: $Updated.wrappedValue)
                        .frame(width: 300, height: 300, alignment: .center)
                }
            }
            .onReceive(Changed.$ChangedFilter, perform:
                        {
                            Value in
                            if Value == BuiltInFilters.Droste.rawValue
                            {
                                ActualPeriodicity = Double(Settings.GetDouble(.DrostePeriodicity, 0.0))
                                CurrentPeriodicity = "\(ActualPeriodicity)"
                                
                                ActualStrands = Double(Settings.GetDouble(.DrosteStrands, 0.0)).RoundedTo(1)
                                CurrentStrands = "\(ActualStrands)"
                                
                                ActualRotation = Double(Settings.GetDouble(.DrosteRotation, 0.0))
                                CurrentRotation = "\(ActualRotation)"
                                
                                ActualZoom = Double(Settings.GetDouble(.DrosteZoom, 0.0))
                                CurrentZoom = "\(ActualZoom)"
                                Updated.toggle()
                            }
                        })
        }
    }
}

struct DrosteFilter_Preview: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        DrosteFilter_View(ButtonCommand: $NotUsed)
            .environmentObject(ChangedSettings())
    }
}
