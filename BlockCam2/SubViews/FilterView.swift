//
//  FilterView.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/24/21.
//

import SwiftUI

/// User interface for the filter groups and filter buttons that let the user select the filter to use
/// for images and live view.
/// - Parameter Width: Width of the parent view.
/// - Parameter Height: Height of the parent view.
/// - Parameter ToolHeight: Height of the tool bar.
/// - Parameter BottomHeight: Height of the bottom tool bar.
/// - Parameter ToggleHidden: Hide or show the filter bar.
/// - Parameter SelectedFilter: Name of the selected filter at the time this view is shown.
/// - Parameter SelectedGroup: Name of the selected group at the time this view is shown.
/// - Parameter Block: Block of code to execute by the filter button.
/// - Parameter SelectedBorderColor: Not surrently used.
struct FilterView: View 
{
    @State var Width: CGFloat
    @State var Height: CGFloat
    @State var ToolHeight: CGFloat
    @State var BottomHeight: CGFloat
    @Binding var ToggleHidden: Bool
    @Binding var SelectedFilter: String
    @Binding var SelectedGroup: String
    @State var Block: ((String) -> ())?
    @State var SelectedBorderColor: Color = Color(UIColor.link)
    
    var body: some View
    {
        GeometryReader
        {
            Geometry in
            VStack(spacing: 2.0)
            {
                ScrollView(.horizontal)
                {
                    HStack(alignment: .center)
                    {
                        ForEach(FilterData.GroupListWithIDs(), id: \.id)
                        {
                            Name in
                            GroupButton(Name: Name.Value, SelectedButton: $SelectedGroup)
                        }
                    }
                    .frame(height: Geometry.size.height / 2)
                    .padding(.all, 2.0)
                }
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.GroupUpdate))
                {
                    Changed in
                    SelectedGroup = Settings.GetString(.CurrentGroup, "Reset")
                }
                
                Divider()
                
                ScrollView(.horizontal, showsIndicators: true)
                {
                    HStack(alignment: .center)
                    {
                        ForEach(FilterData.FilterListWithIDs(Group: SelectedGroup), id: \.id)
                        {
                            Name in
                            FilterButton(Name: Name.Value,
                                         SelectedFilter: $SelectedFilter,
                                         Block: $Block,
                                         SelectedGroup: SelectedGroup)
                        }
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.FilterUpdate))
                {
                    Changed in
                    SelectedFilter = Settings.GetString(.CurrentFilter, "")
                }
                .frame(height: Geometry.size.height / 2)
                .padding(.all, 2.0)
            }
        }
        .padding(.leading, 4.0)
        .frame(width: Width, height: ToolHeight)
        .background(Color.init(UIColor.black.withAlphaComponent(0.65)))
        .position(x: ToggleHidden ? -Width / 2 : Width / 2,
                  y: (Height - ToolHeight / 2) - (ToolHeight / 2) + (BottomHeight * 0.5 / 2))
        .animation(.linear(duration: ToggleHidden ? 0.35 : 0.2))
        .transition(.slide)
    }
}

struct FilterView_Preview: PreviewProvider
{
    @State static var Hidden: Bool = false
    @State static var FilterButton: String = ""
    @State static var GroupButton: String = ""
    
    static var previews: some View
    {
        VStack
        {
            Button(Hidden ? "Show filters" : "Hide filters")
            {
                Hidden.toggle()
            }
                .padding()
            FilterView(Width: 500,
                       Height: 1200,
                       ToolHeight: 150,
                       BottomHeight: 64,
                       ToggleHidden: $Hidden,
                       SelectedFilter: $FilterButton,
                       SelectedGroup: $GroupButton)
        }
    }
}
