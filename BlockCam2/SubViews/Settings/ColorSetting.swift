//
//  ColorSetting.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/13/21.
//

import SwiftUI

struct ColorSetting: View
{
    @State var Title: String
    @State var SubTitle: String
    @State var SettingColor: Color
    @Binding var Result: Color
    @State var Width: CGFloat
    @State var Updated: Bool = false
    
    var body: some View
    {
        HStack
        {
            VStack
            {
                Text(Title)
                    .foregroundColor(SettingColor)
                    .font(.headline)
                    .frame(width: Width * 0.5,
                           alignment: .leading)
                Text(SubTitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(width: Width * 0.5,
                           alignment: .leading)
            }
            ColorPicker("", selection: $SettingColor)
                .onChange(of: SettingColor)
                {
                    NewColor in
                    Updated.toggle()
                    SettingColor = NewColor
                    Result = NewColor
                    print("Got new color")
                }
        }
        .padding()
        .frame(width: Width * 0.9,
               alignment: .center)
    }
}

struct ColorSetting_Previews: PreviewProvider
{
    @State static var TitleValue = "Sample Color"
    @State static var SubTitleValue = "Sample color for some setting."
    @State static var SampleColor = Color(UIColor.systemYellow)
    @State static var Color1Result: Color = Color.white
    @State static var Title2 = "Second Color"
    @State static var SubTitle2 = "Second sub-title goes here."
    @State static var SampleColor2 = Color(UIColor.systemBlue)
    @State static var Color2Result: Color = Color.white
    @State static var Title3 = "Third Color"
    @State static var SubTitle3 = "Third sub-title goes here. This sub-title is really really really long."
    @State static var SampleColor3 = Color(UIColor.systemPurple)
    @State static var Color3Result: Color = Color.white
    
    static var previews: some View
    {
        GeometryReader
        {
            Geometry in
            VStack
            {
        ColorSetting(Title: TitleValue,
                     SubTitle: SubTitleValue,
                     SettingColor: SampleColor,
                     Result: $Color1Result,
                     Width: Geometry.size.width)
            .onChange(of: Color1Result)
            {
                NewColor in
                print("Color 1 changed.")
            }
            
            ColorSetting(Title: Title2,
                         SubTitle: SubTitle2,
                         SettingColor: SampleColor2,
                         Result: $Color2Result,
                         Width: Geometry.size.width)
            
            ColorSetting(Title: Title3,
                         SubTitle: SubTitle3,
                         SettingColor: SampleColor3,
                         Result: $Color3Result,
                         Width: Geometry.size.width)
            }
        }
    }
}
