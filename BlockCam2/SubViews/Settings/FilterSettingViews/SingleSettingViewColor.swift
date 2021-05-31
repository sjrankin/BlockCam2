//
//  SingleSettingViewColor.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/30/21.
//

import Foundation
import SwiftUI

struct SingleSettingViewColor: View
{
    @State var Key: SettingKeys
    @State var Title: String
    @State var SubTitle: String
    @State var ColorTitle: String = ""
    @State var ColorValue: Color = Color.black
    @Binding var Updated: Bool
    
    var body: some View
    {
        let ColorBinding = Binding<Color>(
            get: {self.ColorValue},
            set: {self.ColorValue = $0}
        )
        
        GeometryReader
        {
            Geometry in
            HStack
            {
                VStack(alignment: .leading)
                {
                    Text(Title)
                        .font(.headline)
                        .frame(width: Geometry.size.width * 0.75,
                               alignment: .leading)
                    Text(SubTitle)
                        .font(.subheadline)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(.gray)
                        .frame(width: Geometry.size.width * 0.75,
                               alignment: .leading)
                }
                .frame(width: Geometry.size.width * 0.75)
                ColorPicker(ColorTitle, selection: ColorBinding)
                    .onChange(of: ColorValue)
                    {
                        NewValue in
                        print("Have new color")
                        Settings.SetColor(Key, UIColor(NewValue))
                        self.ColorValue = NewValue
                        Updated.toggle()
                    }
                    .frame(width: Geometry.size.width * 0.2)
            }
        }
    }
}

struct SingleSettingViewColor_Previews: PreviewProvider
{
    @State static var TestTitle: String = "Test"
    @State static var TestSubTitle: String = "This is a test of the test to test the test."
    @State static var TestColorTitle: String = ""
    @State static var Updated: Bool = false
    @State static var Key: SettingKeys = .ColorRangeOutOfRangeColor
    @State static var TestColor: Color = Color.green
    
    static var previews: some View
    {
        VStack
        {
            Divider()
                .background(Color.black)
            
            SingleSettingViewColor(Key: Key,
                                    Title: TestTitle,
                                    SubTitle: TestSubTitle,
                                    Updated: $Updated)
                .padding()
                .onChange(of: Updated)
                {
                    NewValue in
                    print("Updated")
                }
            
            Divider()
                .background(Color.black)
        }
    }
}
