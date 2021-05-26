//
//  Divider2.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/26/21.
//

import SwiftUI

//https://stackoverflow.com/questions/58787180/how-to-change-width-of-divider-in-swiftui
struct Divider2: View
{
    @State var Width: CGFloat
    @State var Height: CGFloat
    @Environment(\.colorScheme) var Scheme
    
    var body: some View
    {
        ZStack
        {
            Rectangle()
                .fill(Scheme == .dark ? Color.gray : Color.black)
                .frame(width: Width, height: Height, alignment: .center)
                .edgesIgnoringSafeArea(.horizontal)
        }
    }
}

struct Divider2_Previews: PreviewProvider
{
    static var previews: some View
    {
        Divider2(Width: 400, Height: 5)
    }
}
