//
//  FilterButton.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/25/21.
//

import SwiftUI

struct FilterButton: View
{
    @State var Name: String
    @Binding var SelectedFilter: String
    @Binding var Block: ((String) -> ())?
    @State var SelectedGroup: String
    @State private var Phase: CGFloat = 0
    var SelectedBorderColor: Color = Color(UIColor.cyan)
    
    var body: some View
    {
        Button(action:
                {
                    Settings.SetString(.CurrentGroup, SelectedGroup)
                    SelectedFilter = Name
                    Block?("Filters.\(Name)")
                })
        {
            Text(Name)
                .font(.custom("Avenir-Medium", size: 18.0))
                .foregroundColor(.black)
                .padding(.horizontal, 3)
                .padding(.vertical, 10)
                .shadow(radius: 5)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
        }
        .frame(width: 110, height: 50)
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
