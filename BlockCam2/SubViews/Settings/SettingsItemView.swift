//
//  SettingsItemView.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/27/21.
//

import SwiftUI

struct SettingsItemView: View
{
    @State var SettingData: OptionItem
    
    var body: some View
    {
        Image(systemName: SettingData.Picture)
            .foregroundColor(Color(UIColor.link))
        VStack(alignment: .leading)
        {
            Text(SettingData.Title)
                .fontWeight(.bold)
            Text(SettingData.Annotation)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}
