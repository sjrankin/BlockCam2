//
//  MetalPixellateFilter_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/19/21.
//

import Foundation
import SwiftUI

struct MetalPixellateFilter_View: View
{
    @Binding var ButtonCommand: String
    @EnvironmentObject var Changed: ChangedSettings
    @State var PixelWidth: Int = Settings.GetInt(.MetalPixWidth)
    @State var PixelHeight: Int = Settings.GetInt(.MetalPixHeight)
    @State var Updated: Bool = false
    @State var InvertThreshold: Bool = Settings.GetBool(.MetalPixInvertThreshold)
    @State var ColorDetermination: Int = Settings.GetInt(.MetalPixColorDetermination)
    @State var MergeImage: Bool = Settings.GetBool(.MetalPixMergeImage)
    @State var HighlightPixel: Int = Settings.GetInt(.MetalPixHighlightPixel)
    @State var HighlightThreshold: Double = Settings.GetDouble(.MetalPixThreshold, 0.5)
    @State var CurrentThreshold: String = Settings.GetDouble(.MetalPixThreshold, 0.5).RoundedTo(2, PadTo: 2)
    
    var body: some View
    {
        GeometryReader
        {
            Geometry in
            ScrollView
            {
                VStack
                {
                    Group
                    {
                    VStack(alignment: .leading)
                    {
                        Text("Block size")
                            .font(.headline)
                            .frame(width: Geometry.size.width * 0.8,
                                   alignment: .leading)
                        Text("Size of the block representing the pixellated area.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: Geometry.size.width * 0.8,
                                   alignment: .leading)
                    }
                    .padding([.leading, .trailing])
                    
                    VStack
                    {
                        HStack
                        {
                            Text("Width")
                                .padding([.leading, .trailing])
                            Picker(selection: $PixelWidth,
                                   label: Text(""))
                            {
                                Text("8").tag(8)
                                Text("16").tag(16)
                                Text("24").tag(24)
                                Text("48").tag(48)
                                Text("64").tag(64)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        .padding([.leading, .trailing])
                        .onChange(of: PixelWidth)
                        {
                            Value in
                            Settings.SetInt(.MetalPixWidth, Value)
                            Updated.toggle()
                        }
                    }
                    .padding([.leading, .trailing])
                    
                    VStack
                    {
                        HStack
                        {
                            Text("Height")
                                .padding([.leading, .trailing])
                            Picker(selection: $PixelHeight,
                                   label: Text(""))
                            {
                                Text("8").tag(8)
                                Text("16").tag(16)
                                Text("24").tag(24)
                                Text("48").tag(48)
                                Text("64").tag(64)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        .padding([.leading, .trailing])
                        .onChange(of: PixelHeight)
                        {
                            Value in
                            Settings.SetInt(.MetalPixHeight, Value)
                            Updated.toggle()
                        }
                    }
                    .padding([.leading, .trailing])
                    
                    Divider()
                        .background(Color.black)
                    }
                    
                    Group
                    {
                    VStack
                    {
                        Text("Color determination")
                            .font(.headline)
                            .frame(width: Geometry.size.width * 0.8,
                                   alignment: .leading)
                        Picker(selection: $ColorDetermination,
                               label: Text(""))
                        {
                            Text("Center").tag(0)
                            Text("Mean Color").tag(1)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding([.leading, .trailing])
                        .onChange(of: ColorDetermination)
                        {
                            NewValue in
                            Settings.SetInt(.MetalPixColorDetermination, NewValue)
                            Updated.toggle()
                        }
                    }
                    
                    Divider()
                        .background(Color.black)

                    VStack(alignment: .leading)
                    {
                        Text("Highlight Pixels")
                            .font(.headline)
                            .padding([.leading, .trailing])

                        Picker(selection: $HighlightPixel,
                               label: Text(""))
                        {
                            Text("Hue").tag(0)
                            Text("Saturation").tag(1)
                            Text("Brightness").tag(2)
                            Text("None").tag(3)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding([.leading, .trailing])
                        .onChange(of: HighlightPixel)
                        {
                            NewValue in
                            Settings.SetInt(.MetalPixHighlightPixel, NewValue)
                            Updated.toggle()
                        }
                        
                        HStack
                        {
                            Text("Threshold")
                            Slider(value: Binding(
                                get:
                                    {
                                        self.HighlightThreshold
                                    },
                                set:
                                    {
                                        NewValue in
                                        self.HighlightThreshold = NewValue.RoundedTo(2)
                                        CurrentThreshold = NewValue.RoundedTo(2, PadTo: 2)
                                        Settings.SetDouble(.MetalPixThreshold, NewValue)
                                        Updated.toggle()
                                    }
                            ), in: 0.0 ... 1.0)
                            .frame(width: Geometry.size.width * 0.5)
                            .padding([.leading, .trailing])
                            
                            Text($CurrentThreshold.wrappedValue)
                        }
                        .padding([.leading, .trailing, .top])
                        
                        HStack
                        {
                            Toggle("Invert threshold",
                                   isOn: Binding(
                                    get:
                                        {
                                            self.InvertThreshold
                                        },
                                    set:
                                        {
                                            NewValue in
                                            self.InvertThreshold = NewValue
                                            Settings.SetBool(.MetalPixInvertThreshold, NewValue)
                                            Updated.toggle()
                                        }
                                   )
                            )
                            .padding([.leading, .trailing])
                        }
                    }

                    Divider()
                        .background(Color.black)
                    
                    HStack
                    {
                        VStack(alignment: .leading)
                        {
                            Text("Merge")
                                .font(.headline)
                                .frame(width: Geometry.size.width * 0.5,
                                       alignment: .leading)
                            Text("Merge result with background image.")
                                .font(.subheadline)
                                .lineLimit(3)
                                .foregroundColor(.gray)
                                .frame(width: Geometry.size.width * 0.55,
                                       alignment: .leading)
                        }
                        
                        Toggle("", isOn: Binding(
                            get:
                                {
                                    self.MergeImage
                                },
                            set:
                                {
                                    NewValue in
                                    self.MergeImage = NewValue
                                    Settings.SetBool(.MetalPixMergeImage, NewValue)
                                    Updated.toggle()
                                }
                        ))
                        .frame(width: Geometry.size.width * 0.3,
                               alignment: .trailing)
                    }
                    .padding([.leading, .trailing])
                    }
                    
                    Divider()
                        .background(Color.black)
                    
                    SampleImage(UICommand: $ButtonCommand,
                                Filter: .MetalPixellate,
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

struct MetalPixellateFilter_Preview: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        MetalPixellateFilter_View(ButtonCommand: $NotUsed)
            .environmentObject(ChangedSettings())
    }
}
