//
//  SingleSettingViewToggle.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/30/21.
//

import SwiftUI

struct SingleSettingViewToggle: View
{
    @State var Key: SettingKeys
    @State var Title: String
    @State var SubTitle: String
    @State var ToggleTitle: String = ""
    @State var ToggleValue: Bool = true
    @Binding var Updated: Bool
    
    var body: some View
    {
        let bind = Binding<Bool>(
            get: {self.ToggleValue},
            set: {self.ToggleValue = $0}
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
                        .frame(width: Geometry.size.width * 0.65,
                               alignment: .leading)
                    Text(SubTitle)
                        .font(.subheadline)
                        .lineLimit(2)
                        .foregroundColor(.gray)
                        .frame(width: Geometry.size.width * 0.65,
                               alignment: .leading)
                }
                .frame(width: Geometry.size.width * 0.65)
                Toggle(ToggleTitle, isOn: bind)
                    .onChange(of: ToggleValue)
                    {
                        NewValue in
                        print("NewValue=\(NewValue)")
                        Settings.SetBool(Key, NewValue)
                        Updated.toggle()
                    }
                    .frame(width: Geometry.size.width * 0.2)
            }
        }
    }
}

struct SingleSettingViewToggle_Previews: PreviewProvider
{
    @State static var TestTitle: String = "Test"
    @State static var TestSubTitle: String = "This is a test of the test to test the test."
    @State static var TestToggleTitle: String = ""
    @State static var Updated: Bool = false
    @State static var Key: SettingKeys = .ColorRangeInvertRange
    
    static var previews: some View
    {
        VStack
        {
            Divider()
                .background(Color.black)
            
            SingleSettingViewToggle(Key: Key,
                                    Title: TestTitle,
                                    SubTitle: TestSubTitle,
                                    ToggleValue: Settings.GetBool(Key),
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
