//
//  ColorMonochromeFilter_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/5/21.
//

import Foundation
import SwiftUI

struct ColorMonochromeFilter_View: View
{
    @Binding var ButtonCommand: String
    @EnvironmentObject var Changed: ChangedSettings
    @State var Updated: Bool = false
    @State var MonoColor: Color = Color(Settings.GetColor(.ColorMonochromeColor, UIColor.green))
    
    var body: some View
    {
        GeometryReader
        {
            Geometry in
            ScrollView
            {
                HStack
                {
                    VStack(alignment: .leading)
                    {
                        Text("Color")
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                        Text("Color to use for the monochrome image.")
                            .frame(minWidth: 300)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                    }
                    Spacer()
                    ColorPicker("", selection: $MonoColor)
                        .onChange(of: MonoColor)
                        {
                            _ in
                            Settings.SetColor(.ColorMonochromeColor, UIColor(MonoColor))
                            Updated.toggle()
                        }
                }
                .padding()
                Spacer()
                Spacer()
                SampleImage(UICommand: $ButtonCommand,
                            Filter: .ColorMonochrome,
                            Updated: $Updated.wrappedValue)
                    .frame(width: 300, height: 300, alignment: .center)
            }
        }
        .onReceive(Changed.$ChangedFilter, perform:
                    {
                        Value in
                        if Value == BuiltInFilters.ColorMonochrome.rawValue
                        {
                            MonoColor = Color(Settings.GetColor(.ColorMonochromeColor, UIColor.green))
                            Updated.toggle()
                        }
                    })
    }
}

struct ColorMonochromeFilter_Preview: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        ColorMonochromeFilter_View(ButtonCommand: $NotUsed)
            .environmentObject(ChangedSettings())
    }
}
