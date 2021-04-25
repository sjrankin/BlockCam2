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
    @State var IsSelected: Bool
    @State var SelectedFilter: String
    @State var Block: ((String) -> ())?
    
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
        }
        .foregroundColor(.black)
        .background(
            ZStack
            {
                RoundedRectangle(cornerRadius: 10.0)
                    .stroke(Color.white,
                            lineWidth: 5)
                    .shadow(radius: 5)
                RoundedRectangle(cornerRadius: 10.0)
                    .fill(Color.gray)
                    .shadow(radius: 5)
            }
        )
        .padding(.leading, 5)
        .padding(.bottom, 40)
        .padding(.top, 12)
    }
}
