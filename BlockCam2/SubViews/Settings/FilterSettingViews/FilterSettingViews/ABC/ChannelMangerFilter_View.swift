//
//  ChannelMangerFilter_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/16/21.
//

import Foundation
import SwiftUI

struct ChannelManglerFilter_View: View
{
    @Binding var ButtonCommand: String
    @EnvironmentObject var Changed: ChangedSettings
    @State var MangleOperation: Int = Settings.GetInt(.ChannelManglerOperation)
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
                            Text("Mangle Operation")
                            Text("Select the method to use to mangle the channels.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Picker(selection: $MangleOperation,
                                   label: Text(ChannelMangler.MangleTypes[MangleOperation]!.Command))
                            {
                                ForEach(0 ..< ChannelMangler.MangleTypes.count, id: \.self)
                                {
                                    Index in
                                    Text(ChannelMangler.MangleTypes[Index]!.Command)
                                }
                            }
                            .onChange(of: MangleOperation)
                            {
                                Value in
                                Settings.SetInt(.ChannelManglerOperation, Value)
                                Updated.toggle()
                            }
                            .pickerStyle(WheelPickerStyle())
                        }
                    }
                    .padding()
                }
                Divider()
                    .background(Color.black)

                Text(ChannelMangler.MangleTypes[MangleOperation]!.Description)
                    .lineLimit(4)
                    .font(.subheadline)
                    .frame(minHeight: 50)
                    .padding()
                
                Divider()
                    .background(Color.black)
                
                SampleImage(UICommand: $ButtonCommand,
                            Filter: .ChannelMangler,
                            Updated: $Updated.wrappedValue)
                    .frame(width: 300, height: 300, alignment: .center)
            }
        }
        .onReceive(Changed.$ChangedFilter, perform:
                    {
                        Value in
                        MangleOperation = Settings.GetInt(.ChannelManglerOperation)
                        Updated.toggle()
                    })
    }
}

struct ChannelManglerFilter_Preview: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        ChannelManglerFilter_View(ButtonCommand: $NotUsed)
            .environmentObject(ChangedSettings())
    }
}
