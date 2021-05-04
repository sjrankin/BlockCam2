//
//  ColorMapFilter_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/4/21.
//

import Foundation
import SwiftUI

struct ColorMapFilter_View: View
{
    @State var Color1: Color = Color.white
    @State var Color2: Color = Color.black
    @State var Gradient: String = Settings.GetString(.ColorMapGradient, Settings.SettingDefaults[.ColorMapGradient] as! String)
    
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
                    Text("Top Color")
                        .padding(.trailing)
                    Text("Top color of the gradient.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.trailing)
                    }
                    Spacer()
                    ColorPicker("", selection: $Color1)
                        .onChange(of: "selectedColor", perform:
                                    { value in
                            print("New color!")
                        })
                }
                .padding()
                HStack
                {
                    VStack(alignment: .leading)
                    {
                        Text("Bottom Color")
                            .padding(.trailing)
                        Text("Bottom color of the gradient.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.trailing)
                    }
                    Spacer()
                    ColorPicker("", selection: $Color2)
                }
                .padding()
                Spacer()
            }
        }
    }
}

struct ColorMapFilter_Preview: PreviewProvider
{
    static var previews: some View
    {
        ColorMapFilter_View()
    }
}
