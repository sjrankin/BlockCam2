//
//  Solarization2Filter_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/17/21.
//

import Foundation
import SwiftUI

struct SolarizationHSBFilter_View: View
{
    @Binding var ButtonCommand: String
    @EnvironmentObject var Changed: ChangedSettings
    @State var Updated: Bool = false
    @State var SolarizeHow: Int = 0
    @State var ChannelName: String = "All Channels"
    @State var ChannelThreshold: Double = 0.5
    @State var ChannelThresholdString: String = "0.5"
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
                        Settings.SetInt(.SolarizeHow, Value)
                        switch Value
                        {
                            case 0:
                                ChannelName = "All Channels"
                                MaxRange = 1.0
                                ChannelThreshold = Settings.GetDouble(.SolarizeThresholdHigh).RoundedTo(2)
                                ChannelThresholdString = Settings.GetDouble(.SolarizeThresholdHigh).RoundedTo(2, PadTo: 2)
                                
                            case 1:
                                ChannelName = "Hue"
                                MaxRange = 360.0
                                ChannelThreshold = (Settings.GetDouble(.SolarizeHighHue) * 360.0).RoundedTo(2)
                                ChannelThresholdString = Settings.GetDouble(.SolarizeHighHue).RoundedTo(2, PadTo: 2)
                                
                            case 2:
                                ChannelName = "Saturation"
                                MaxRange = 1.0
                                ChannelThreshold = Settings.GetDouble(.SolarizeSaturationThresholdHigh).RoundedTo(2)
                                ChannelThresholdString = Settings.GetDouble(.SolarizeSaturationThresholdHigh).RoundedTo(2, PadTo: 2)
                                
                            case 3:
                                ChannelName = "Brightness"
                                MaxRange = 1.0
                                ChannelThreshold = Settings.GetDouble(.SolarizeBrightnessThresholdHigh).RoundedTo(2)
                                ChannelThresholdString = Settings.GetDouble(.SolarizeBrightnessThresholdHigh).RoundedTo(2, PadTo: 2)
                                
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
                                Text("Threshold")
                                Slider(value: Binding(
                                    get:
                                        {
                                            self.ChannelThreshold
                                        },
                                    set:
                                        {
                                            (newValue) in
                                            self.ChannelThreshold = newValue.RoundedTo(2)
                                            ChannelThresholdString = self.ChannelThreshold.RoundedTo(2, PadTo: 2)
                                            Updated.toggle()
                                            switch SolarizeHow
                                            {
                                                case 0:
                                                    Settings.SetDouble(.SolarizeThresholdHigh, ChannelThreshold)
                                                    
                                                case 1:
                                                    Settings.SetDouble(.SolarizeHighHue, ChannelThreshold / 360.0)
                                                    
                                                case 2:
                                                    Settings.SetDouble(.SolarizeSaturationThresholdHigh, ChannelThreshold)
                                                    
                                                case 3:
                                                    Settings.SetDouble(.SolarizeSaturationThresholdHigh, ChannelThreshold)
                                                    
                                                default:
                                                break
                                            }
                                        }
                                ), in: 0 ... MaxRange)
                                .accentColor(Color(UIColor.systemTeal))
                                .padding([.leading, .trailing])
                                .frame(width: Geometry.size.width * 0.5)
                                Text(ChannelThresholdString + "\(SolarizeHow == 1 ? "°" : "")")
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
                            }
                        }
                        .padding()
                        
                        Spacer()
                        
                    }
                    Spacer()
                    Divider()
                        .background(Color.black)
                    SampleImage(UICommand: $ButtonCommand,
                                Filter: .SolarizeHSB,
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
                            SolarizeHow = Settings.GetInt(.SolarizeHow)
                            SolarizeIfGreater = Settings.GetBool(.SolarizeIfGreater)
                            switch SolarizeHow
                            {
                                case 0:
                                    ChannelName = "All Channels"
                                    MaxRange = 1.0
                                    ChannelThreshold = Settings.GetDouble(.SolarizeThresholdHigh).RoundedTo(2)
                                    ChannelThresholdString = Settings.GetDouble(.SolarizeThresholdHigh).RoundedTo(2, PadTo: 2)
                                    
                                case 1:
                                    ChannelName = "Hue"
                                    MaxRange = 360.0
                                    ChannelThreshold = (Settings.GetDouble(.SolarizeHighHue) * 360.0).RoundedTo(2)
                                    ChannelThresholdString = Settings.GetDouble(.SolarizeHighHue).RoundedTo(2, PadTo: 2)
                                    
                                case 2:
                                    ChannelName = "Saturation"
                                    MaxRange = 1.0
                                    ChannelThreshold = Settings.GetDouble(.SolarizeSaturationThresholdHigh).RoundedTo(2)
                                    ChannelThresholdString = Settings.GetDouble(.SolarizeSaturationThresholdHigh).RoundedTo(2, PadTo: 2)
                                    
                                case 3:
                                    ChannelName = "Brightness"
                                    MaxRange = 1.0
                                    ChannelThreshold = Settings.GetDouble(.SolarizeBrightnessThresholdHigh).RoundedTo(2)
                                    ChannelThresholdString = Settings.GetDouble(.SolarizeBrightnessThresholdHigh).RoundedTo(2, PadTo: 2)
                                    
                                default:
                                    break
                            }
                            Updated.toggle()
                        }
                    })
    }
}

struct SolarizationHSBFilter_Preview: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        SolarizationHSBFilter_View(ButtonCommand: $NotUsed)
            .environmentObject(ChangedSettings())
    }
}
