//
//  FilterTableEntryView.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/25/21.
//

import SwiftUI

struct FilterTableEntryView: View
{
    @EnvironmentObject var Changed: ChangedSettings
    @State var FilterName: String
    @State var FilterDescription: String
    @State var OverallWidth: CGFloat
    @State var ActualFilter: BuiltInFilters
    @Binding var CurrentFilter: BuiltInFilters
    @State var UICommand: String = ""
    @State var ShowSettings: Bool = false
    @State var IsLastInGroup: Bool
    
    var body: some View
    {
        HStack
        {
            VStack
            {
                Text(FilterName)
                    .font(.headline)
                    .frame(width: OverallWidth * 0.8,
                           alignment: .leading)
                    .shadow(radius: ActualFilter == CurrentFilter ? 5.0 : 0.0)
                Text(FilterDescription)
                    .frame(width: OverallWidth * 0.8,
                           alignment: .leading)
                    .font(.subheadline)
                    .foregroundColor(ActualFilter != CurrentFilter ? .gray : .black)
            }
            Button(action:
                    {
                        ShowSettings = true
                    },
                   label:
                    {
                        Image(systemName: "slider.horizontal.3")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24, alignment: .trailing)
                    })
                .disabled(ActualFilter != CurrentFilter)
                .opacity(ActualFilter == CurrentFilter ? 1.0 : 0.0)
        }
        .frame(width: OverallWidth * 0.95)
        .background(ActualFilter == CurrentFilter ? Color.yellow : Color.white)
        .padding(5)
        .onTapGesture
        {
            //If the user taps a filter, switch to it. Other parts of the UI and
            //code are notified via user settings and the Notification Center.
            Settings.SetString(.CurrentFilter, ActualFilter.rawValue)
            let GroupForFilter = Filters.GroupFor(Filter: ActualFilter)
            Settings.SetString(.CurrentGroup, GroupForFilter.rawValue)
            CurrentFilter = ActualFilter
            let GInfo: [AnyHashable: Any] = ["GroupName": GroupForFilter.rawValue]
            NotificationCenter.default.post(name: NSNotification.GroupUpdate,
                                            object: nil,
                                            userInfo: GInfo)
            let FInfo: [AnyHashable: Any] = ["FilterName": ActualFilter.rawValue]
            NotificationCenter.default.post(name: NSNotification.FilterUpdate,
                                            object: nil,
                                            userInfo: FInfo)
        }
        .sheet(isPresented: $ShowSettings)
        {
            FilterViewServer(UICommand: $UICommand,
                             IsVisible: $ShowSettings)
                .environmentObject(Changed)
        }
        Divider2(Width: OverallWidth, Height: IsLastInGroup ? 2.0 : 0.5)
    }
}

struct FilterTableEntryView_Previews: PreviewProvider
{
    @State static var Items: [ItemState] =
        [
            ItemState(id: "1", WasTapped: false, ItemName: "Filter1",
                      IsSelected: false, TappedName: "", Description: "Filter 1 description"),
            ItemState(id: "2", WasTapped: false, ItemName: "Filter2",
                      IsSelected: false, TappedName: "", Description: "Filter 2 description"),
            ItemState(id: "3", WasTapped: false, ItemName: "Filter3",
                      IsSelected: false, TappedName: "", Description: "Filter 3 description"),
            ItemState(id: "4", WasTapped: false, ItemName: "Filter4",
                      IsSelected: false, TappedName: "", Description: "Filter 4 description"),
            ItemState(id: "5", WasTapped: false, ItemName: "Filter5",
                      IsSelected: false, TappedName: "", Description: "Filter 5 description"),
        ]
    @State static var FilterList: [BuiltInFilters] =
        [
            .Passthrough,
            .Noir,
            .HatchedScreen,
            .Blocks,
            .HeightField
        ]
    @State static var InitialFilter: BuiltInFilters = .Passthrough
    
    static var previews: some View
    {
        GeometryReader
        {
            Reader in
            LazyVStack
            {
                ForEach(0 ..< Items.count, id: \.self)
                {
                    Index in
                    FilterTableEntryView(FilterName: Items[Index].ItemName,
                                         FilterDescription: Items[Index].Description,
                                         OverallWidth: Reader.size.width,
                                         ActualFilter: FilterList[Index],
                                         CurrentFilter: $InitialFilter,
                                         IsLastInGroup: false)
                        .environmentObject(ChangedSettings())
                }
            }
        }
    }
}
