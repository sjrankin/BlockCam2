//
//  ConditionalSilhouetteFilter_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/16/21.
//

import Foundation
import SwiftUI

struct ConditionalSilhouetteFilter_View: View
{
    @Binding var ButtonCommand: String
    @EnvironmentObject var Changed: ChangedSettings
    @State var Trigger: Int = Settings.GetInt(.ConditionalSilhouetteTrigger)
    @State var SilhouetteColor: Color = Color(Settings.GetColor(.ConditionalSilhouetteColor, UIColor.black))
    @State var SelectedChannel: String = "Hue"
    @State var EditedColor: Color = Color.black
    @State var Threshold: Double = Settings.GetDouble(.ConditionalSilhouetteHueThreshold, 0.5).RoundedTo(2)
    @State var ThresholdString: String = Settings.GetDouble(.ConditionalSilhouetteHueThreshold, 0.5).RoundedTo(2, PadTo: 2)
    @State var Range: Double = Settings.GetDouble(.ConditionalSilhouetteHueRange, 0.05).RoundedTo(2)
    @State var RangeString: String = Settings.GetDouble(.ConditionalSilhouetteHueRange, 0.05).RoundedTo(2, PadTo: 2)
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
                            Text("Silhouette Trigger")
                            Text("Select trigger for silhouetting.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Picker(selection: $Trigger,
                                   label: Text(""))
                            {
                                Text("Hue").tag(0)
                                Text("Saturation").tag(1)
                                Text("Brightness").tag(2)
                            }
                        }
                        .onChange(of: Trigger)
                        {
                            Value in
                            switch Value
                            {
                                case 0:
                                    SelectedChannel = "Hue"
                                    Threshold = Settings.GetDouble(.ConditionalSilhouetteHueThreshold, 0.5).RoundedTo(2)
                                    Range = Settings.GetDouble(.ConditionalSilhouetteHueRange, 0.05).RoundedTo(2)
                                    ThresholdString = Threshold.RoundedTo(2, PadTo: 2)
                                    RangeString = Range.RoundedTo(2, PadTo: 2)
                                    
                                case 1:
                                    SelectedChannel = "Saturation"
                                    Threshold = Settings.GetDouble(.ConditionalSilhouetteSatThreshold, 0.5).RoundedTo(2)
                                    Range = Settings.GetDouble(.ConditionalSilhouetteSatRange, 0.05).RoundedTo(2)
                                    ThresholdString = Threshold.RoundedTo(2, PadTo: 2)
                                    RangeString = Range.RoundedTo(2, PadTo: 2)
                                    
                                case 2:
                                    SelectedChannel = "Brightness"
                                    Threshold = Settings.GetDouble(.ConditionalSilhouetteBriThreshold, 0.5).RoundedTo(2)
                                    Range = Settings.GetDouble(.ConditionalSilhouetteBriRange, 0.05).RoundedTo(2)
                                    ThresholdString = Threshold.RoundedTo(2, PadTo: 2)
                                    RangeString = Range.RoundedTo(2, PadTo: 2)
                                    
                                default:
                                    SelectedChannel = "Unknown"
                            }
                            Settings.SetInt(.ConditionalSilhouetteTrigger, Value)
                            Updated.toggle()
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding([.leading, .trailing])
                    }
                    .padding()
                    
                    Divider()
                        .background(Color.black)
                    
                    VStack(alignment: .leading)
                    {
                        Text(SelectedChannel)
                            .font(.headline)
                        HStack
                        {
                            Text("Threshold")
                                .font(.subheadline)
                            
                            Slider(value: Binding(
                                get:
                                    {
                                        self.Threshold
                                    },
                                set:
                                    {
                                        (newValue) in
                                        self.Threshold = newValue
                                        ThresholdString = self.Threshold.RoundedTo(2, PadTo: 2)
                                        switch Trigger
                                        {
                                            case 0:
                                                Settings.SetDouble(.ConditionalSilhouetteHueThreshold, Threshold)
                                            
                                            case 1:
                                                Settings.SetDouble(.ConditionalSilhouetteSatThreshold, Threshold)
                                            
                                            case 2:
                                                Settings.SetDouble(.ConditionalSilhouetteBriThreshold, Threshold)
                                            
                                            default:
                                                break
                                        }
                                        Updated.toggle()
                                    }
                            ), in: 0.0 ... 1.0)
                            .frame(width: Geometry.size.width * 0.45)
                            .padding([.leading, .trailing])
                            
                            Text(ThresholdString)
                                .font(Font.system(.body, design: .monospaced).monospacedDigit())
                                .multilineTextAlignment(.trailing)
                        }
                        HStack
                        {
                            Text("Range")
                                .font(.subheadline)
                            
                            Slider(value: Binding(
                                get:
                                    {
                                        self.Range
                                    },
                                set:
                                    {
                                        (newValue) in
                                        self.Range = newValue
                                        RangeString = self.Range.RoundedTo(2, PadTo: 2)
                                        switch Trigger
                                        {
                                            case 0:
                                                Settings.SetDouble(.ConditionalSilhouetteHueRange, Range)
                                                
                                            case 1:
                                                Settings.SetDouble(.ConditionalSilhouetteSatRange, Range)
                                                
                                            case 2:
                                                Settings.SetDouble(.ConditionalSilhouetteBriRange, Range)
                                                
                                            default:
                                                break
                                        }
                                        Updated.toggle()
                                    }
                            ), in: 0.0 ... 0.25)
                            .frame(width: Geometry.size.width * 0.45)
                            .padding([.leading, .trailing])
                            
                            Text(RangeString)
                                .font(Font.system(.body, design: .monospaced).monospacedDigit())
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    
                    Divider()
                        .background(Color.black)
                    
                    HStack
                    {
                        VStack
                        {
                            Text("Silhouette Color")
                                .font(.headline)
                                .frame(width: Geometry.size.width * 0.5,
                                       alignment: .leading)
                            Text("Color of the silhouette")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(width: Geometry.size.width * 0.5,
                                       alignment: .leading)
                        }
                        ColorPicker("", selection: $SilhouetteColor)
                            .onChange(of: SilhouetteColor)
                            {
                                NewColor in
                                Settings.SetColor(.ConditionalSilhouetteColor, UIColor(NewColor))
                                Updated.toggle()
                            }
                    }
                    .padding()
                    .frame(width: Geometry.size.width * 0.9,
                           alignment: .center)
                    
                    Spacer()
                    
                    Divider()
                        .background(Color.black)
                    
                    SampleImage(UICommand: $ButtonCommand,
                                Filter: .ConditionalSilhouette,
                                Updated: $Updated.wrappedValue)
                        .frame(width: 300, height: 300, alignment: .center)
                }
            }
        }
        .onReceive(Changed.$ChangedFilter, perform:
                    {
                        Value in
                        Trigger = Settings.GetInt(.ConditionalSilhouetteTrigger)
                        SilhouetteColor = Color(Settings.GetColor(.ConditionalSilhouetteColor, UIColor.black))
                        Threshold = Settings.GetDouble(.ConditionalSilhouetteHueThreshold, 0.5).RoundedTo(2)
                        Range = Settings.GetDouble(.ConditionalSilhouetteHueRange, 0.05).RoundedTo(2)
                        ThresholdString = Threshold.RoundedTo(2, PadTo: 2)
                        RangeString = Range.RoundedTo(2, PadTo: 2)
                        Updated.toggle()
                    })
    }
}

struct ConditionalSilhouetteFilter_Preiew: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        ConditionalSilhouetteFilter_View(ButtonCommand: $NotUsed)
            .environmentObject(ChangedSettings())
    }
}
