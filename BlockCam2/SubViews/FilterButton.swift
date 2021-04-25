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
    var SelectedBorderColor: Color = Color(UIColor.link)
    
    var body: some View
    {
        Button(action:
                {
                    SelectedFilter = Name
                    Block?("Filters.\(Name)")
                })
        {
            Text(Name)
                .font(.custom("Avenir-Heavy", size: 20.0))
                .foregroundColor(.black)
                .padding(.horizontal, 3)
                .padding(.vertical, 10)
                .shadow(radius: 5)
        }
        .foregroundColor(.black)
        .background(
            ZStack
            {
                RoundedRectangle(cornerRadius: 10.0)
                    .stroke(SelectedFilter == Name ? SelectedBorderColor : Color.white,
                            style: StrokeStyle(
                                lineWidth: SelectedFilter == Name ? 10 : 5,
                                dash: SelectedFilter == Name ? [5, 5] : []
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
