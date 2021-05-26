//
//  AllFiltersByGroupView.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/25/21.
//

import SwiftUI

struct AllFiltersByGroupView: View
{
    @EnvironmentObject var Changed: ChangedSettings
    @State var StartingFilter: BuiltInFilters = BuiltInFilters(rawValue: Settings.GetString(.CurrentFilter, "No Filter"))!
    @State var Width: CGFloat
    @State var GroupedFilters: [(GroupName: String, GroupFilters: [(String, String, BuiltInFilters)])] = Filters.DisplayTree
    
    var body: some View
    {
        ScrollView
        {
            ForEach(0 ..< GroupedFilters.count, id: \.self)
            {
                Index in
                Section(header: SectionHeader(HeaderText: GroupedFilters[Index].GroupName))
                {
                    ForEach(0 ..< GroupedFilters[Index].GroupFilters.count, id: \.self)
                    {
                        FilterIndex in
                        FilterTableEntryView(FilterName: GroupedFilters[Index].GroupFilters[FilterIndex].0,
                                             FilterDescription: GroupedFilters[Index].GroupFilters[FilterIndex].1,
                                             OverallWidth: Width,
                                             ActualFilter: GroupedFilters[Index].GroupFilters[FilterIndex].2,
                                             CurrentFilter: $StartingFilter,
                                             IsLastInGroup: FilterIndex == GroupedFilters[Index].GroupFilters.count - 1)
                            .environmentObject(Changed)
                    }
                }.listStyle(GroupedListStyle())
            }
        }
    }
}

//https://stackoverflow.com/questions/59751721/swiftui-how-to-add-an-underline-to-a-text-view
struct SectionHeader: View
{
    @State var HeaderText: String
    
    var body: some View
    {
        VStack(alignment: .leading)
        {
            HStack
            {
                Text(HeaderText)
                    .underline(true, color: Color.black)
                    .frame(alignment: .leading)
                    .foregroundColor(Color(UIColor(red: 0.2, green: 0.2, blue: 0.5, alpha: 1.0)))
                    .font(.custom("Avenir-Black", size: 22.0))
                Spacer()
                Text(Filters.GroupDescription(For: HeaderText))
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(alignment: .trailing)
            }
            .padding([.leading, .trailing])
        }
    }
}

struct AllFiltersByGroupView_Previews: PreviewProvider
{
    static var previews: some View
    {
        AllFiltersByGroupView(Width: 400)
            .environmentObject(ChangedSettings())
    }
}
