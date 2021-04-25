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
    @State var ItemsForGroup: Int = 0
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
                            Button(action:
                                    {
                                        SelectedGroup = Name.Value
                                        ItemsForGroup = FilterData.IndexOf(Group: Name.Value)
                                    })
                            {
                                Text(Name.Value)
                                    .font(.custom("Avenir-Black", size: 24.0))
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 10)
                            }
                            .background(
                                ZStack
                                {
                                    RoundedRectangle(cornerRadius: 10.0)
                                        .stroke(SelectedGroup == Name.Value ? SelectedBorderColor : Color.white,
                                                lineWidth: SelectedGroup == Name.Value ? 10 : 5)
                                        .shadow(radius: 5)
                                    RoundedRectangle(cornerRadius: 10.0)
                                        .fill(Color(FilterData.GroupColor(With: Name.Value)))
                                        .shadow(radius: 5)
                                })
                            .foregroundColor(.black)
                            .padding(.leading, 5)
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
                        ForEach(FilterData.FilterListWithIDs(Index: ItemsForGroup), id: \.id)
                        {
                            Name in
                            Button(action:
                                    {
                                        SelectedFilter = Name.Value
                                        Block?("Filters.\(Name.Value)")
                                    })
                            {
                                Text(Name.Value)
                                    .font(.custom("Avenir-Heavy", size: 20.0))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 3)
                                    .padding(.vertical, 10)
                            }
                            .foregroundColor(.black)
                            .background(
                                ZStack
                                {
                                    RoundedRectangle(cornerRadius: 10.0)
                                        .stroke(SelectedFilter == Name.Value ? SelectedBorderColor : Color.white,//Color.white,
                                                lineWidth: SelectedFilter == Name.Value ? 10 : 5)
                                        .shadow(radius: 5)
                                    RoundedRectangle(cornerRadius: 10.0)
                                        .fill(Color(FilterData.GroupColor(For: ItemsForGroup)))
                                        .shadow(radius: 5)
                                }
                            )
                            .padding(.leading, 5)
                            .padding(.bottom, 40)
                            .padding(.top, 12)
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
