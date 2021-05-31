//
//  CheckerboardGenerator_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/31/21.
//

import Foundation
import SwiftUI

struct CheckerboardGenerator_View: View
{
    @EnvironmentObject var Changed: ChangedSettings
    @Binding var ButtonCommand: String
    @State var Updated: Bool = false
    @State var DimIndex: Int = 0
    var Dimensions = ["256x256", "512x512", "1024x1024"]
    @State var SquareSizes: Int = Settings.GetInt(.MCheckerCheckSize)
    @State var Color0: Color = Color(Settings.GetColor(.MCheckerColor0, UIColor.black))
    @State var Color1: Color = Color(Settings.GetColor(.MCheckerColor1, UIColor.white))
    @State var Color2: Color = Color(Settings.GetColor(.MCheckerColor2, UIColor.black))
    @State var Color3: Color = Color(Settings.GetColor(.MCheckerColor3, UIColor.white))
    
    var body: some View
    {
        GeometryReader
        {
            Geometry in
            ScrollView
            {
                Group
                {
                    VStack(alignment: .leading)
                    {
                        Text("Size")
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                        Text("Width and height of each color square.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                        Picker("", selection: $SquareSizes)
                        {
                            Text("8").tag(8)
                            Text("16").tag(16)
                            Text("32").tag(32)
                            Text("64").tag(64)
                            Text("128").tag(128)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .padding([.leading, .trailing])
                    
                    Divider()
                        .background(Color.black)
                }
                
                Group
                {
                    VStack(alignment: .leading)
                    {
                        Text("Image Size")
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                        Text("Dimensions of the final image.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                        Picker("", selection: $DimIndex)
                        {
                            ForEach(0 ..< Dimensions.count, id: \.self)
                            {
                                Index in
                                Text(Dimensions[Index]).tag(Index)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .padding([.leading, .trailing])
                    
                    Divider()
                        .background(Color.black)
                }
                
                Group
                {
                    VStack
                    {
                        ColorPicker("Color 0 (upper-left)", selection: $Color0)
                        ColorPicker("Color 1 (upper-right)", selection: $Color1)
                        ColorPicker("Color 2 (lower-right)", selection: $Color2)
                        ColorPicker("Color 3 (lower-left)", selection: $Color3)
                    }
                    .padding([.leading, .trailing])
                    
                    Divider()
                        .background(Color.black)
                }
                
                Group
                {
                Button("Generate")
                {
                    Updated.toggle()
                }
                    
                    Divider()
                        .background(Color.black)
                    
                Spacer()
                }
                
                Image(uiImage: MetalCheckerboard.Generate(Block: SquareSizes,
                                                          Width: 256,
                                                          Height: 256,
                                                          Color0: UIColor(Color0),
                                                          Color1: UIColor(Color1),
                                                          Color2: UIColor(Color2),
                                                          Color3: UIColor(Color3)))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 256, height: 256, alignment: .center)
            }
            .padding()
        }
        .onReceive(Changed.$ChangedFilter, perform:
                    {
                        Value in
                        if Value == BuiltInFilters.MetalCheckerboard.rawValue
                        {
                            SquareSizes = Settings.GetInt(.MCheckerCheckSize)
                            Color0 = Color(Settings.GetColor(.MCheckerColor0, UIColor.black))
                            Color1 = Color(Settings.GetColor(.MCheckerColor1, UIColor.white))
                            Color2 = Color(Settings.GetColor(.MCheckerColor2, UIColor.black))
                            Color3 = Color(Settings.GetColor(.MCheckerColor3, UIColor.white))
                            Updated.toggle()
                        }
                    })
    }
}

struct CheckerboardGenerator_Preview: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        CheckerboardGenerator_View(ButtonCommand: $NotUsed)
            .environmentObject(ChangedSettings())
    }
}
