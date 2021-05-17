//
//  ChannelMixerFilter_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/15/21.
//

import Foundation
import SwiftUI

struct ChannelMixerFilter_View: View 
{
    @Binding var ButtonCommand: String
    @EnvironmentObject var Changed: ChangedSettings
    @State var Channel1Input: Int = Settings.GetInt(.ChannelMixerChannel1)
    @State var Channel2Input: Int = Settings.GetInt(.ChannelMixerChannel2)
    @State var Channel3Input: Int = Settings.GetInt(.ChannelMixerChannel3)
    @State var Channel1Invert: Bool = Settings.GetBool(.ChannelMixerInvertChannel1)
    @State var Channel2Invert: Bool = Settings.GetBool(.ChannelMixerInvertChannel2)
    @State var Channel3Invert: Bool = Settings.GetBool(.ChannelMixerInvertChannel3)
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
                            Text("Red Channel")
                            Text("Select the input for the red channel.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            HStack
                            {
                                Picker(selection: $Channel1Input,
                                       label: Text(ChannelMixer.ChannelNames[Channel1Input]!))
                                {
                                    ForEach(0 ..< ChannelMixer.ChannelNames.count, id: \.self)
                                    {
                                        Index in
                                        Text(ChannelMixer.ChannelNames[Index]!)
                                    }
                                }
                            .onChange(of: Channel1Input)
                            {
                                Value in
                                Settings.SetInt(.ChannelMixerChannel1, Value)
                                Updated.toggle()
                            }
                            .pickerStyle(MenuPickerStyle())
                            Spacer()
                            Toggle("Invert Channel", isOn: Binding(
                                get:
                                    {
                                        self.Channel1Invert
                                    },
                                set:
                                    {
                                        NewValue in
                                        self.Channel1Invert = NewValue
                                        Settings.SetBool(.ChannelMixerInvertChannel1, NewValue)
                                        Updated.toggle()
                                    }
                            ))
                            .frame(width: Geometry.size.width * 0.4)
                        }
                        }
                        .padding()
                    }
                    Divider()
                        .background(Color.black)
                    
                    HStack
                    {
                        VStack(alignment: .leading)
                        {
                            Text("Green Channel")
                            Text("Select the input for the green channel.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            HStack
                            {
                                Picker(selection: $Channel2Input,
                                       label: Text(ChannelMixer.ChannelNames[Channel2Input]!))
                                {
                                    ForEach(0 ..< ChannelMixer.ChannelNames.count, id: \.self)
                                    {
                                        Index in
                                        Text(ChannelMixer.ChannelNames[Index]!)
                                    }
                                }
                                .onChange(of: Channel2Input)
                                {
                                    Value in
                                    Settings.SetInt(.ChannelMixerChannel2, Value)
                                    Updated.toggle()
                                }
                                .pickerStyle(MenuPickerStyle())
                                Spacer()
                                Toggle("Invert Channel", isOn: Binding(
                                    get:
                                        {
                                            self.Channel2Invert
                                        },
                                    set:
                                        {
                                            NewValue in
                                            self.Channel2Invert = NewValue
                                            Settings.SetBool(.ChannelMixerInvertChannel2, NewValue)
                                            Updated.toggle()
                                        }
                                ))
                                .frame(width: Geometry.size.width * 0.4)
                            }
                        }
                        .padding()
                    }
                    
                    Divider()
                        .background(Color.black)
                    
                    HStack
                    {
                        VStack(alignment: .leading)
                        {
                            Text("Blue Channel")
                            Text("Select the input for the blue channel.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            HStack
                            {
                                Picker(selection: $Channel3Input,
                                       label: Text(ChannelMixer.ChannelNames[Channel3Input]!))
                                {
                                    ForEach(0 ..< ChannelMixer.ChannelNames.count, id: \.self)
                                    {
                                        Index in
                                        Text(ChannelMixer.ChannelNames[Index]!)
                                    }
                                }
                                .onChange(of: Channel3Input)
                                {
                                    Value in
                                    Settings.SetInt(.ChannelMixerChannel3, Value)
                                    Updated.toggle()
                                }
                                .pickerStyle(MenuPickerStyle())
                                Spacer()
                                Toggle("Invert Channel", isOn: Binding(
                                    get:
                                        {
                                            self.Channel3Invert
                                        },
                                    set:
                                        {
                                            NewValue in
                                            self.Channel3Invert = NewValue
                                            Settings.SetBool(.ChannelMixerInvertChannel3, NewValue)
                                            Updated.toggle()
                                        }
                                ))
                                .frame(width: Geometry.size.width * 0.4)
                            }
                        }
                        .padding()
                    }
                    
                    Divider()
                        .background(Color.black)
                    
                    SampleImage(UICommand: $ButtonCommand,
                                Filter: .ChannelMixer,
                                Updated: $Updated.wrappedValue)
                        .frame(width: 300, height: 300, alignment: .center)
                }
            }
        }
        .onReceive(Changed.$ChangedFilter, perform:
                    {
                        Value in
                        Channel1Input = Settings.GetInt(.ChannelMixerChannel1)
                        Channel1Invert = Settings.GetBool(.ChannelMixerInvertChannel1)
                        Channel2Input = Settings.GetInt(.ChannelMixerChannel2)
                        Channel2Invert = Settings.GetBool(.ChannelMixerInvertChannel2)
                        Channel3Input = Settings.GetInt(.ChannelMixerChannel3)
                        Channel3Invert = Settings.GetBool(.ChannelMixerInvertChannel3)
                        Updated.toggle()
                    })
    }
}

struct ChannelMixerFilter_Preview: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        ChannelMixerFilter_View(ButtonCommand: $NotUsed)
            .environmentObject(ChangedSettings())
    }
}
