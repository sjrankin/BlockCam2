//
//  FilterView.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/24/21.
//

import SwiftUI

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
                .frame(height: Geometry.size.height / 2)
                .padding(.all, 2.0)
            }
        }
        .padding(.leading, 4.0)
        .frame(width: Width, height: ToolHeight)
        .background(Color.init(UIColor.black.withAlphaComponent(0.65)))
        .position(x: ToggleHidden ? -Width / 2 : Width / 2,
                  y: (Height - ToolHeight / 2) - (ToolHeight / 2) + (BottomHeight * 0.5 / 2))
        .animation(.linear(duration: ToggleHidden ? 0.1 : 0.2))
        .transition(.slide)
    }
}
