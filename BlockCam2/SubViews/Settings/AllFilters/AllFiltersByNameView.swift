//
//  AllFiltersByNameView.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/25/21.
//

import SwiftUI

struct AllFiltersByNameView: View
{
    @EnvironmentObject var Changed: ChangedSettings
    @State var StartingFilter: BuiltInFilters = BuiltInFilters(rawValue: Settings.GetString(.CurrentFilter, "No Filter"))!
    @State var Width: CGFloat
    
    var body: some View
    {
        ScrollView
        {
            ForEach(0 ..< Filters.AllFilters().count, id: \.self)
            {
                Index in
                FilterTableEntryView(FilterName: Filters.AllFilters()[Index].0,
                                     FilterDescription: Filters.AllFilters()[Index].1,
                                     OverallWidth: Width,
                                     ActualFilter: Filters.AllFilters()[Index].2,
                                     CurrentFilter: $StartingFilter,
                                     IsLastInGroup: false)
                    .environmentObject(Changed)
            }
        }
    }
}

struct AllFiltersByNameView_Previews: PreviewProvider
{
    static var previews: some View
    {
        AllFiltersByNameView(Width: 400)
            .environmentObject(ChangedSettings())
    }
}
