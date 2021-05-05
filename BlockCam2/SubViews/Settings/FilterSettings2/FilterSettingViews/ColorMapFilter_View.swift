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
    @State var Updated: Bool = false
    @State var Options: [FilterOptions: Any] = [FilterOptions.GradientDefinition: Settings.GetString(.ColorMapGradient, Settings.SettingDefaults[.ColorMapGradient] as! String)]
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
                            .frame(minWidth: 200)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.trailing)
                    }
                    Spacer()
                    ColorPicker("", selection: $Color1)
                        .onChange(of: Color1)
                        {
                            _ in
                            let NewGradient = GradientManager.AssembleGradient([(UIColor(Color1), 0.0), (UIColor(Color2), 1.0)])
                            Gradient = NewGradient
                            Settings.SetString(.ColorMapGradient, NewGradient)
                            Options[.GradientDefinition] = NewGradient
                        }
                }
                .padding()
                HStack
                {
                    VStack(alignment: .leading)
                    {
                        Text("Bottom Color")
                            .padding(.trailing)
                        Text("Bottom color of the gradient.")
                            .frame(minWidth: 200)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.trailing)
                    }
                    Spacer()
                    ColorPicker("", selection: $Color2)
                        .onChange(of: Color2)
                        {
                            _ in
                            let NewGradient = GradientManager.AssembleGradient([(UIColor(Color1), 0.0), (UIColor(Color2), 1.0)])
                            Gradient = NewGradient
                            Settings.SetString(.ColorMapGradient, NewGradient)
                            Options[.GradientDefinition] = NewGradient
                        }
                }
                .padding()
                Spacer()
                Spacer()
                Image(uiImage: GradientManager.CreateGradientImage(From: $Gradient.wrappedValue,
                                                                   WithFrame: CGRect(origin: CGPoint.zero,
                                                                                     size: CGSize(width: 200, height: 200))))
                    .padding()
                Spacer()
                #if true
                SampleImage(Filter: .ColorMap, Updated: $Updated.wrappedValue)
                    .frame(width: 300, height: 300, alignment: .center)
                #else
                SampleImage(FilterOptions: $Options, Filter: .ColorMap)
                    .frame(width: 300, height: 300, alignment: .center)
                #endif
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
