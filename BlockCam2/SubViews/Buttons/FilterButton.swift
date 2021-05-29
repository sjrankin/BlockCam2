//
//  FilterButton.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/25/21.
//

import SwiftUI

struct TitleView: View
{
    @State var Title: String
    
    var body: some View
    {
        if Filters.TitleHasSymbol(Title)
        {
            HStack
            {
                Text(Title)
                    .allowsTightening(true)
                    .minimumScaleFactor(0.75)
                    .foregroundColor(.black)
                    .padding(.horizontal, 2)
                    .padding(.vertical, 10)
                    .shadow(radius: 5)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                Image(systemName: Filters.GetTitleSymbol(For: Title))
            }
        }
        else
        {
            Text(Title)
                .allowsTightening(true)
                .minimumScaleFactor(0.75)
                .foregroundColor(.black)
                .padding(.horizontal, 2)
                .padding(.vertical, 10)
                .shadow(radius: 5)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
        }
    }
}

//https://www.davidgagne.net/2020/09/30/dealing-with-word-breaks-in-swiftui-text/
struct FilterButton: View
{
    @State var Name: String
    @Binding var SelectedFilter: String
    @Binding var Block: ((String) -> ())?
    @State var SelectedGroup: String
    @State private var Phase: CGFloat = 0
    var SelectedBorderColor: Color = Color(UIColor.cyan)
    let Slow = Image(systemName: "tortoise")
    let Video = Image(systemName: "rectangle.stack")
    
    var body: some View
    {
        Button(action:
                {
                    Settings.SetString(.CurrentGroup, SelectedGroup)
                    SelectedFilter = Name
                    Block?("Filters.\(Name)")
                })
        {
            TitleView(Title: Name)
        }
        .frame(width: 120, height: 50)
        .foregroundColor(.black)
        .background(
            ZStack
            {
                RoundedRectangle(cornerRadius: 10.0)
                    .stroke(SelectedFilter == Name ? SelectedBorderColor : Color.black,
                            style: StrokeStyle(
                                lineWidth: SelectedFilter == Name ? 10 : 5,
                                dash: SelectedFilter == Name ? [5, 5] : [],
                                dashPhase: Phase
                            ))
                RoundedRectangle(cornerRadius: 10.0)
                    .fill(Color(FilterData.GroupColor(With: SelectedGroup)))
            }
        )
        .padding(.leading, 5)
        .padding(.bottom, 40)
        .padding(.top, 12)
    }
}
