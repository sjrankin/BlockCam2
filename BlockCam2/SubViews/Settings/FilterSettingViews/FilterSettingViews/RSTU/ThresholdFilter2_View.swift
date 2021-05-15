//
//  ThresholdFilter2_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/13/21.
//

import SwiftUI

struct ThresholdFilter2_View: View
{
    @Binding var ButtonCommand: String
    @EnvironmentObject var Changed: ChangedSettings
    @State var Updated: Bool = false
    @State var ThresholdString: String = "\(Settings.GetDouble(.ThresholdValue, 0.5).RoundedTo(2))"
    @State var ThresholdValue: Double = Settings.GetDouble(.ThresholdValue, 0.5).RoundedTo(2)
    @State var ChannelValue: Int = Settings.GetInt(.ThresholdInputChannel)
    var ChannelNames = ["Red", "Green", "Blue", "Hue", "Saturation", "Brightness", "Cyan", "Magenta", "Yellow", "Black"]
    @State var ApplyIfGreater: Bool = Settings.GetBool(.ThresholdApplyIfGreater)
    @State var LowColor: Color = Color(Settings.GetColor(.ThresholdLowColor) ?? UIColor.white)
    @State var HighColor: Color = Color(Settings.GetColor(.ThresholdHighColor) ?? UIColor.black)
    
    var body: some View
    {
        GeometryReader
        {
            Geometry in
            ScrollView
            {
                VStack(alignment: .leading)
                {
                    Text("Threshold value")
                        .font(.headline)
                    Text("The value of the channel where change takes place.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .frame(height: 40)
                    HStack
                    {
                    Slider(value: Binding(
                        get:
                            {
                                return self.ThresholdValue
                            },
                        set:
                            {
                                NewValue in
                                self.ThresholdValue = NewValue.RoundedTo(2)
                                ThresholdString = self.ThresholdValue.RoundedTo(2, PadTo: 2)
                                Settings.SetDouble(.ThresholdValue, self.ThresholdValue)
                                print("New threshold value=\(self.ThresholdValue)")
                                Updated.toggle()
                            }
                    ), in: 0.0 ... 1.0)
                        Text("\(ThresholdString)")
                            .font(Font.system(.body, design: .monospaced).monospacedDigit())
                            .frame(width: 60)
                    }
                }
                .padding()
                .frame(width: Geometry.size.width * 0.9,
                       alignment: .leading)
                
                HStack
                {
                    VStack(alignment: .leading)
                    {
                        Text("Apply if Greater")
                            .font(.headline)
                        Text("Apply the threshold if the channel value is greater.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(width: Geometry.size.width * 0.5,
                           alignment: .leading)
    
                    Toggle(isOn: self.$ApplyIfGreater)
                    {
                        Text("")
                    }
                    .frame(width: Geometry.size.width * 0.3,
                           alignment: .leading)
                    .onReceive([self.$ApplyIfGreater].publisher.first())
                    {
                        Value in
                        Settings.SetBool(.ThresholdApplyIfGreater, Value.wrappedValue)
                        Updated.toggle()
                    }
                }
                .padding()
                .frame(width: Geometry.size.width * 0.9,
                       alignment: .leading)

                HStack
                {
                    VStack(alignment: .leading)
                    {
                        Text("Channel")
                            .font(.headline)
                        Text("Select the channel to use to determine the threshold.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(width: Geometry.size.width * 0.5,
                           alignment: .leading)
                    .padding()
                    Picker(selection: $ChannelValue, label: Text(ChannelNames[$ChannelValue.wrappedValue]))
                    {
                        Text("Red").tag(0)
                        Text("Green").tag(1)
                        Text("Blue").tag(2)
                        Text("Hue").tag(3)
                        Text("Saturation").tag(4)
                        Text("Brightness").tag(5)
                        Text("Cyan").tag(6)
                        Text("Magenta").tag(7)
                        Text("Yellow").tag(8)
                        Text("Black").tag(9)
                    }
                    .onChange(of: ChannelValue, perform:
                                {
                                    Value in
                                    Settings.SetInt(.ThresholdInputChannel, Value)
                                    Updated.toggle()
                                })
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: Geometry.size.width * 0.3,
                           alignment: .center)
                }
                .padding()
                
                HStack
                {
                    VStack
                    {
                        Text("High Color")
                            .foregroundColor(.black)
                            .font(.headline)
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                        Text("The color to apply if the channel is over the threshold")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                    }
                    ColorPicker("", selection: $HighColor)
                        .onChange(of: HighColor)
                        {
                            NewColor in
                            Updated.toggle()
                            print("Got new color")
                        }
                }
                .padding()
                .frame(width: Geometry.size.width * 0.9,
                       alignment: .center)
                
                HStack
                {
                    VStack
                    {
                        Text("Low Color")
                            .foregroundColor(.black)
                            .font(.headline)
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                        Text("The color to apply if the channel is under the threshold")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                    }
                    ColorPicker("", selection: $LowColor)
                        .onChange(of: LowColor)
                        {
                            NewColor in
                            Updated.toggle()
                            print("Got new color")
                        }
                }
                .padding()
                .frame(width: Geometry.size.width * 0.9,
                       alignment: .center)
                
                Spacer()
                
                Divider()
                    .background(Color.black)
                SampleImage(UICommand: $ButtonCommand,
                            Filter: .Threshold,
                            Updated: $Updated.wrappedValue)
                    .frame(width: 300, height: 300, alignment: .center)
            }
        }
        .onReceive(Changed.$ChangedFilter, perform:
                    {
                        Value in
                        if Value == BuiltInFilters.ColorMap.rawValue
                        {
                            LowColor = Color(Settings.GetColor(.ThresholdLowColor) ?? UIColor.white)
                            HighColor = Color(Settings.GetColor(.ThresholdHighColor) ?? UIColor.black)
                            ChannelValue = Settings.GetInt(.ThresholdInputChannel)
                            ThresholdValue = Settings.GetDouble(.ThresholdValue,
                                                                Settings.SettingDefaults[.ThresholdValue] as! Double)
                            ApplyIfGreater = Settings.GetBool(.ThresholdApplyIfGreater)
                            Updated.toggle()
                        }
                    })
    }
}

struct ThresholdFilter2_View_Previews: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        ThresholdFilter2_View(ButtonCommand: $NotUsed)
            .environmentObject(ChangedSettings())
    }
}
