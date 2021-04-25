//
//  GroupButton.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/25/21.
//

import SwiftUI

struct GroupButton: View
{
    @State var Name: String
    @Binding var SelectedButton: String
    var SelectedBorderColor: Color = Color(UIColor.link)
    
    var body: some View
    {
        Button(action:
                {
                    SelectedButton = Name
                })
        {
            Text(Name)
                .font(.custom("Avenir-Black", size: 24.0))
                .padding(.horizontal, 5)
                .padding(.vertical, 10)
                .shadow(radius: 5)
        }
        .background(
            ZStack
            {
                RoundedRectangle(cornerRadius: 10.0)
                    .stroke(SelectedButton == Name ? SelectedBorderColor : Color.white,
                            style: StrokeStyle(
                                lineWidth: SelectedButton == Name ? 10 : 5,
                                dash: SelectedButton == Name ? [5, 5] : []
                            ))
                RoundedRectangle(cornerRadius: 10.0)
                    .fill(Color(FilterData.GroupColor(With: Name)))
            })
        .foregroundColor(.black)
        .padding(.leading, 5)
    }
}
