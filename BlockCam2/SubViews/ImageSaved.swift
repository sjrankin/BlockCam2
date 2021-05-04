//
//  ImageSaved.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/24/21.
//

import SwiftUI

struct ImageSaved: View
{
    @Binding var IsVisible: Bool
    @Binding var Message: String
    @State var Width: CGFloat
    @State var Height: CGFloat
    
    var body: some View
    {
        Text(Message)
            .foregroundColor(.black)
            .font(.custom("Avenir-Heavy", size: 30.0))
            .padding()
            .background(
                ZStack
                {
                    RoundedRectangle(cornerRadius: 10.0)
                        .stroke(Color.black, lineWidth: 5)
                        .shadow(radius: 5)
                    RoundedRectangle(cornerRadius: 10.0)
                        .fill(Color(UIColor.systemGray2))
                        .shadow(radius: 3)
                }
                .shadow(radius: 5)
                .frame(width: 375, height: 50)
            )
            .frame(width: Width * 0.75,
                   height: 50.0,
                   alignment: .top)
            .position(x: IsVisible ? Width / 2 : -Width / 2,
                      y: 200 / 2)
            .animation(.linear(duration: IsVisible ? 0.2 : 0.15))
            .transition(.slide)
    }
}

