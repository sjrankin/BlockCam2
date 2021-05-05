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
    @State var Updated: Bool = false
    @State var Options: [FilterOptions: Any] =
        [.Color: Settings.GetColor(.ColorMonochromeColor) as Any]
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
                            .padding(.trailing)
                        Text("Color to use for the monochrome image.")
                            .frame(minWidth: 300)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.trailing)
                    }
                    Spacer()
                    ColorPicker("", selection: $MonoColor)
                        .onChange(of: MonoColor)
                        {
                            _ in
                            Settings.SetColor(.ColorMonochromeColor, UIColor(MonoColor))
                            Options[.Color] = UIColor(MonoColor)
                        }
                }
                .padding()
                Spacer()
                Spacer()
                #if true
                SampleImage(Filter: .ColorMonochrome, Updated: $Updated.wrappedValue)
                    .frame(width: 300, height: 300, alignment: .center)
                #else
                SampleImage(FilterOptions: $Options, Filter: .ColorMonochrome)
                    .frame(width: 300, height: 300, alignment: .center)
                #endif
            }
        }
    }
}

struct ColorMonochromeFilter_Preview: PreviewProvider
{
    static var previews: some View
    {
        ColorMonochromeFilter_View()
    }
}
