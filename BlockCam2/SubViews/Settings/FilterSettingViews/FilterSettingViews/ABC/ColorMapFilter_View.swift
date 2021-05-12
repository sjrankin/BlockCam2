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
    @Binding var ButtonCommand: String
    @EnvironmentObject var Changed: ChangedSettings
    @State var Gradient: String = GradientManager.AssembleGradient([(Settings.GetColor(.ColorMapColor1) ?? UIColor.white, 0.0),
                                                                    (Settings.GetColor(.ColorMapColor2) ?? UIColor.black, 1.0)])
    @State var Updated: Bool = false
    @State var Color1: Color = Color(Settings.GetColor(.ColorMapColor1) ?? UIColor.white)
    @State var Color2: Color = Color(Settings.GetColor(.ColorMapColor2) ?? UIColor.black)
    
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
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                        Text("Top color of the gradient.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                    }
                    .padding()
                    Spacer()
                    ColorPicker("", selection: $Color1)
                        .onChange(of: Color1)
                        {
                            _ in
                            Settings.SetColor(.ColorMapColor1, UIColor(Color1))
                            Gradient = GradientManager.AssembleGradient([(UIColor($Color1.wrappedValue), 0.0),
                                                                         (UIColor($Color2.wrappedValue), 1.0)])
                            Updated.toggle()
                        }
                        .padding()
                }

                HStack
                {
                    VStack(alignment: .leading)
                    {
                        Text("Bottom Color")
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                        Text("Bottom color of the gradient.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                    }
                    .padding()
                    Spacer()
                    ColorPicker("", selection: $Color2)
                        .onChange(of: Color2)
                        {
                            _ in
                            Settings.SetColor(.ColorMapColor2, UIColor(Color2))
                            Gradient = GradientManager.AssembleGradient([(UIColor($Color1.wrappedValue), 0.0),
                                                                         (UIColor($Color2.wrappedValue), 1.0)])
                            Updated.toggle()
                        }
                        .padding()
                }

                Spacer()
                Spacer()
                Image(uiImage: GradientManager.CreateGradientImage(From: $Gradient.wrappedValue,
                                                                   WithFrame: CGRect(origin: CGPoint.zero,
                                                                                     size: CGSize(width: 200, height: 200))))
                    .border(Color.black, width: 0.5)
                    .padding()
                Spacer()
                SampleImage(UICommand: $ButtonCommand,
                    Filter: .ColorMap,
                            Updated: $Updated.wrappedValue)
                    .frame(width: 300, height: 300, alignment: .center)
            }
        }
        .onReceive(Changed.$ChangedFilter, perform:
                    {
                        Value in
                        if Value == BuiltInFilters.ColorMap.rawValue
                        {
                            Gradient = GradientManager.AssembleGradient([(Settings.GetColor(.ColorMapColor1) ?? UIColor.white, 0.0),
                                                                                            (Settings.GetColor(.ColorMapColor2) ?? UIColor.black, 1.0)])
                            Color1 = Color(Settings.GetColor(.ColorMapColor1) ?? UIColor.white)
                            Color2 = Color(Settings.GetColor(.ColorMapColor2) ?? UIColor.black)
                            Updated.toggle()
                        }
                    })
    }
}

struct ColorMapFilter_Preview: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        ColorMapFilter_View(ButtonCommand: $NotUsed)
            .environmentObject(ChangedSettings())
    }
}
