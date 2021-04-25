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
    @State var IsSelected: Bool
    @State var SelectedButton: String
    
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
        }
        .background(
            ZStack
            {
                RoundedRectangle(cornerRadius: 10.0)
                    .stroke(Color.white,
                            lineWidth: 5)
                    .shadow(radius: 5)
                RoundedRectangle(cornerRadius: 10.0)
                    .fill(Color(FilterData.GroupColor(With: Name)))
                    .shadow(radius: 5)
            })
        .foregroundColor(.black)
        .padding(.leading, 5)
    }
}
