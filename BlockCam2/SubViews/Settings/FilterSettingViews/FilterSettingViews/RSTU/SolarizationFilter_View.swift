//
//  SolarizationFilter_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/16/21.
//

import Foundation
import SwiftUI

struct SolarizationFilter_View: View
{
    @Binding var ButtonCommand: String
    @EnvironmentObject var Changed: ChangedSettings
    @State var Updated: Bool = false
    @State var SolarizeHow: Int = 0
    @State var ChannelName: String = "All Channels"
    @State var ChannelThresholdLow: Double = 0.5
    @State var ChannelThresholdHigh: Double = 0.6
    @State var ChannelThresholdLowString: String = "0.5"
    @State var ChannelThresholdHighString: String = "0.6"
    @State var MaxRange: Double = 1.0
    @State var SolarizeIfGreater = Settings.GetBool(.SolarizeIfGreater)
    @State var UnitRange: Bool = false
    
    var body: some View
    {
        GeometryReader
        {
            Geometry in
            ScrollView
            {
                VStack
                {
                    VStack(alignment: .leading)
                    {
                        Text("Solarize Channel")
                            .font(.headline)
                        Text("Select the channel to use to determine solarization.")
                        Picker("", selection: $SolarizeHow)
                        {
                            Text("All Channels").tag(0)
                            Text("Hue").tag(1)
                            Text("Saturation").tag(2)
                            Text("Brightness").tag(3)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .onChange(of: SolarizeHow)
                    {
                        Value in
                        switch Value
                        {
                            case 0:
                                ChannelName = "All Channels"
                                MaxRange = 1.0
                                ChannelThresholdHigh = Settings.GetDouble(.SolarizeThresholdHigh).RoundedTo(2)
                                ChannelThresholdHighString = Settings.GetDouble(.SolarizeThresholdHigh).RoundedTo(2, PadTo: 2)
                                if UnitRange
                                {
                                    ChannelThresholdLow = ChannelThresholdHigh
                                    ChannelThresholdLowString = ChannelThresholdHighString
                                }
                                else
                                {
                                    ChannelThresholdLow = Settings.GetDouble(.SolarizeThresholdLow).RoundedTo(2)
                                    ChannelThresholdLowString = Settings.GetDouble(.SolarizeThresholdLow).RoundedTo(2, PadTo: 2)
                                }
                                
                            case 1:
                                ChannelName = "Hue"
                                MaxRange = 360.0
                                ChannelThresholdHigh = Settings.GetDouble(.SolarizeHighHue).RoundedTo(2)
                                ChannelThresholdHighString = Settings.GetDouble(.SolarizeHighHue).RoundedTo(2, PadTo: 2)
                                if UnitRange
                                {
                                    ChannelThresholdLow = ChannelThresholdHigh
                                    ChannelThresholdLowString = ChannelThresholdHighString
                                }
                                else
                                {
                                    ChannelThresholdLow = Settings.GetDouble(.SolarizeLowHue).RoundedTo(2)
                                    ChannelThresholdLowString = Settings.GetDouble(.SolarizeLowHue).RoundedTo(2, PadTo: 2)
                                }
                                
                            case 2:
                                ChannelName = "Saturation"
                                MaxRange = 1.0
                                ChannelThresholdHigh = Settings.GetDouble(.SolarizeSaturationThresholdHigh).RoundedTo(2)
                                ChannelThresholdHighString = Settings.GetDouble(.SolarizeSaturationThresholdHigh).RoundedTo(2, PadTo: 2)
                                if UnitRange
                                {
                                    ChannelThresholdLow = ChannelThresholdHigh
                                    ChannelThresholdLowString = ChannelThresholdHighString
                                }
                                else
                                {
                                    ChannelThresholdLow = Settings.GetDouble(.SolarizeSaturationThresholdLow).RoundedTo(2)
                                    ChannelThresholdLowString = Settings.GetDouble(.SolarizeSaturationThresholdLow).RoundedTo(2, PadTo: 2)
                                }
                                
                            case 3:
                                ChannelName = "Brightness"
                                MaxRange = 1.0
                                ChannelThresholdHigh = Settings.GetDouble(.SolarizeBrightnessThresholdHigh).RoundedTo(2)
                                ChannelThresholdHighString = Settings.GetDouble(.SolarizeBrightnessThresholdHigh).RoundedTo(2, PadTo: 2)
                                if UnitRange
                                {
                                    ChannelThresholdLow = ChannelThresholdHigh
                                    ChannelThresholdLowString = ChannelThresholdHighString
                                }
                                else
                                {
                                    ChannelThresholdLow = Settings.GetDouble(.SolarizeBrightnessThresholdLow).RoundedTo(2)
                                    ChannelThresholdLowString = Settings.GetDouble(.SolarizeBrightnessThresholdLow).RoundedTo(2, PadTo: 2)
                                }
                                
                            default:
                                break
                        }
                    }
                    .padding()
                    Divider()
                        .background(Color.black)
                    HStack
                    {
                        VStack(alignment: .leading)
                        {
                            Text(ChannelName)
                                .frame(alignment: .leading)
                            Text("Channel threshold")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(alignment: .leading)
                            HStack
                            {
                                Text("Low")
                                Slider(value: Binding(
                                    get:
                                        {
                                            self.ChannelThresholdLow
                                        },
                                    set:
                                        {
                                            (newValue) in
                                            self.ChannelThresholdLow = newValue.RoundedTo(2)
                                            ChannelThresholdLowString = self.ChannelThresholdLow.RoundedTo(2, PadTo: 2)
                                            //                                        Settings.SetDouble(.HueAngle, Double(Int(self.ActualAngle)))
                                            if UnitRange
                                            {
                                                ChannelThresholdHigh = ChannelThresholdLow
                                            }
                                            else
                                            {
                                                if self.ChannelThresholdLow > self.ChannelThresholdHigh
                                                {
                                                    self.ChannelThresholdHigh = self.ChannelThresholdLow
                                                }
                                            }
                                            Updated.toggle()
                                        }
                                ), in: 0 ... MaxRange)
                                .accentColor(Color(UIColor.systemTeal))
                                .padding([.leading, .trailing])
                                .frame(width: Geometry.size.width * 0.6)
                                Text(ChannelThresholdLowString + "\(SolarizeHow == 1 ? "°" : "")")
                                    .font(Font.system(.body, design: .monospaced).monospacedDigit())
                                    .multilineTextAlignment(.trailing)
                            }
                            HStack
                            {
                                Text("High")
                                Slider(value: Binding(
                                    get:
                                        {
                                            self.ChannelThresholdHigh
                                        },
                                    set:
                                        {
                                            (newValue) in
                                            self.ChannelThresholdHigh = newValue.RoundedTo(2)
                                            ChannelThresholdHighString = self.ChannelThresholdHigh.RoundedTo(2, PadTo: 2)
                                            //                                        Settings.SetDouble(.HueAngle, Double(Int(self.ActualAngle)))
                                            if UnitRange
                                            {
                                                ChannelThresholdLow = ChannelThresholdHigh
                                            }
                                            else
                                            {
                                                if self.ChannelThresholdLow > self.ChannelThresholdHigh
                                                {
                                                    self.ChannelThresholdLow = self.ChannelThresholdHigh
                                                }
                                            }
                                            Updated.toggle()
                                        }
                                ), in: 0 ... MaxRange)
                                .accentColor(Color(UIColor.systemYellow))
                                .padding([.leading, .trailing])
                                .frame(width: Geometry.size.width * 0.6)
                                Text(ChannelThresholdHighString + "\(SolarizeHow == 1 ? "°" : "")")
                                    .font(Font.system(.body, design: .monospaced).monospacedDigit())
                                    .multilineTextAlignment(.trailing)
                            }
                            VStack
                            {
                                HStack
                                {
                                    Toggle("Solarize if greater", isOn: Binding(
                                        get:
                                            {
                                                self.SolarizeIfGreater
                                            },
                                        set:
                                            {
                                                NewValue in
                                                self.SolarizeIfGreater = NewValue
                                            }
                                    ))
                                }
                                Toggle("Lock high and low", isOn: Binding(
                                    get:
                                        {
                                            self.UnitRange
                                        },
                                    set:
                                        {
                                            NewValue in
                                            self.UnitRange = NewValue
                                            if UnitRange
                                            {
                                                ChannelThresholdLow = ChannelThresholdHigh
                                                switch SolarizeHow
                                                {
                                                    case 0:
                                                        Settings.SetDouble(.SolarizeThresholdLow, ChannelThresholdHigh)
                                                        
                                                    case 1:
                                                        Settings.SetDouble(.SolarizeLowHue, ChannelThresholdHigh)
                                                        
                                                    case 2:
                                                        Settings.SetDouble(.SolarizeSaturationThresholdLow, ChannelThresholdHigh)
                                                        
                                                    case 3:
                                                        Settings.SetDouble(.SolarizeBrightnessThresholdLow, ChannelThresholdHigh)
                                                        
                                                    default:
                                                        break
                                                }
                                            }
                                            else
                                            {
                                                
                                            }
                                        }
                                ))
                            }
                        }
                        .padding()
                        
                        Spacer()
                        
                    }
                    Spacer()
                    Divider()
                        .background(Color.black)
                    SampleImage(UICommand: $ButtonCommand,
                                Filter: .Solarize,
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
                            Updated.toggle()
                        }
                    })
    }
}

struct SolarizationFilter_Preview: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        SolarizationFilter_View(ButtonCommand: $NotUsed)
            .environmentObject(ChangedSettings())
    }
}
