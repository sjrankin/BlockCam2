//
//  AllFilterView.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/25/21.
//

import SwiftUI

struct AllFilterView: View
{
    @EnvironmentObject var Changed: ChangedSettings
    @State var DisplayOrder: Int = 0
    @State var DisplayType: Int = Settings.GetInt(.FilterListDisplay)
    @State var StartingFilter: BuiltInFilters = BuiltInFilters(rawValue: Settings.GetString(.CurrentFilter, "No Filter"))!
    
    var body: some View
    {
        GeometryReader
        {
            Geometry in
            VStack
            {
                Picker("Order by", selection: $DisplayType)
                {
                    Text("Alphabetical").tag(0)
                    Text("Filter Groups").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .onChange(of: DisplayType)
                {
                    NewValue in
                    switch NewValue
                    {
                        case 0:
                            DisplayType = 0
                            Settings.SetInt(.FilterListDisplay, 0)
                            
                        case 1:
                            DisplayType = 1
                            Settings.SetInt(.FilterListDisplay, 1)
                            
                        default:
                            return
                    }
                }
                Text("Tap to select new filter.")
                
                Divider()
                    .background(Color.black)
                
                AllFiltersDependentView(DisplayType: $DisplayType,
                                        Width: Geometry.size.width)
                    .environmentObject(Changed)
            }
            .navigationBarTitle(Text("Filter List"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct AllFilterView_Previews: PreviewProvider
{
    static var previews: some View
    {
        AllFilterView()
    }
}
