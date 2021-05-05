//
//  QuadrantButton.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/1/21.
//

import SwiftUI

struct QuadrantButton: View
{
    @Binding var Quadrant: Int
    @State var ExpectedQuadrant: Int
    @State var ImageAngle: Double
    
    var body: some View
    {
        Image(systemName: "square.split.bottomrightquarter")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 100, height: 100, alignment: .center)
            .foregroundColor(.black)
            .shadow(radius: 3)
            .rotationEffect(Angle(degrees: ImageAngle))
            .background(Quadrant == ExpectedQuadrant ? Color.yellow : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}
