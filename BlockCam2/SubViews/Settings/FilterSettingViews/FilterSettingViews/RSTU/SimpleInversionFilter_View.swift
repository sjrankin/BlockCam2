//
//  SimpleInversionFilter_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 6/1/21.
//

import Foundation
import SwiftUI

struct SimpleInversionFilter_View: View
{
    @Binding var ButtonCommand: String
    @EnvironmentObject var Changed: ChangedSettings
    @State var InvertChannel: Int = Settings.GetInt(.SimpleInversionChannel)
    @State var Updated: Bool = false
    var ChannelList = ["Red", "Green", "Blue", "Hue", "Saturation", "Brightness", "Cyan", "Magenta", "Yellow",
                       "Black"]
    
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
                            Text("Channel")
                            Text("Select the channel to use to invert.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Picker(selection: $InvertChannel,
                                   label: Text(ChannelList[InvertChannel]))
                            {
                                ForEach(0 ..< ChannelList.count, id: \.self)
                                {
                                    Index in
                                    Text(ChannelList[Index]).tag(Index)
                                }
                            }
                            .onChange(of: InvertChannel)
                            {
                                Value in
                                Settings.SetInt(.SimpleInversionChannel, Value)
                                Updated.toggle()
                            }
                            .pickerStyle(WheelPickerStyle())
                        }
                    }
                    .padding()
                }
                
                Divider()
                    .background(Color.black)
                
                SampleImage(UICommand: $ButtonCommand,
                            Filter: .SimpleInversion,
                            Updated: $Updated.wrappedValue)
                    .frame(width: 300, height: 300, alignment: .center)
            }
        }
        .onReceive(Changed.$ChangedFilter, perform:
                    {
                        Value in
                        InvertChannel = Settings.GetInt(.SimpleInversionChannel)
                        Updated.toggle()
                    })
    }
}

struct SimpleInversionFilter_Preview: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        SimpleInversionFilter_View(ButtonCommand: $NotUsed)
            .environmentObject(ChangedSettings())
    }
}
