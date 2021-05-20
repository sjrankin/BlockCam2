//
//  MetalPixellateFilterDetails_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/20/21.
//

import SwiftUI

struct MetalPixellateFilterDetails_View: View
{
    @Environment(\.presentationMode) var presentionMode: Binding<PresentationMode>
    @Binding var ButtonCommand: String
    @EnvironmentObject var Changed: ChangedSettings
    @State var Updated: Bool = false
    @State var InvertThreshold: Bool = Settings.GetBool(.MetalPixInvertThreshold)
    @State var HighlightPixel: Int = Settings.GetInt(.MetalPixHighlightPixel)
    @State var HighlightThreshold: Double = Settings.GetDouble(.MetalPixThreshold, 0.5)
    @State var CurrentThreshold: String = Settings.GetDouble(.MetalPixThreshold, 0.5).RoundedTo(2, PadTo: 2)
    @State var ShowBorders: Bool = Settings.GetBool(.MetalPixShowBorder)
    @State var BorderColor: Color = Color(Settings.GetColor(.MetalPixBorderColor, UIColor.black))
    
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
                    
                    VStack
                    {
                        HStack
                        {
                            VStack
                            {
                            Text("Borders")
                                .font(.headline)
                                .foregroundColor(.black)
                                .frame(width: Geometry.size.width * 0.5,
                                       alignment: .leading)
                            Text("Show borders around pixels")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(width: Geometry.size.width * 0.5,
                                       alignment: .leading)
                            }
                            Toggle("",
                                   isOn: Binding(
                                    get:
                                        {
                                            self.ShowBorders
                                        },
                                    set:
                                        {
                                            NewValue in
                                            self.ShowBorders = NewValue
                                            Settings.SetBool(.MetalPixShowBorder, NewValue)
                                            Updated.toggle()
                                        }
                                   )
                            )
                        }
                        HStack
                        {
                            VStack
                            {
                                Text("Border color")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .frame(width: Geometry.size.width * 0.5,
                                           alignment: .leading)
                                Text("Color of the pixel border")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .frame(width: Geometry.size.width * 0.5,
                                           alignment: .leading)
                            }
                            ColorPicker("", selection: $BorderColor)
                                .onChange(of: BorderColor)
                                {
                                    _ in
                                    Settings.SetColor(.MetalPixBorderColor,
                                                      UIColor(BorderColor))
                                    Updated.toggle()
                                }
                                .padding()
                        }
                    }
                    .padding()
                    
                    Divider()
                        .background(Color.black)
                    
                    SampleImage(UICommand: $ButtonCommand,
                                Filter: .MetalPixellate,
                                Updated: $Updated.wrappedValue)
                        .frame(width: 300, height: 300, alignment: .center)
                }
                .padding(.top)
            }
            .navigationBarTitle("Pixellation Highlighting")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar
            {
                ToolbarItem(placement: .navigationBarTrailing)
                {
                    Button(action:
                            {
                                self.presentionMode.wrappedValue.dismiss()
                            }
                    )
                    {
                        Image(systemName: "xmark.circle.fill")
                    }
                }
            }
        }
    }
}

struct MetalPixellateFilterDetails_View_Previews: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        MetalPixellateFilterDetails_View(ButtonCommand: $NotUsed)
            .environmentObject(ChangedSettings())
    }
}
