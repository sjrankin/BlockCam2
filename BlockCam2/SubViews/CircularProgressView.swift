//
//  CircularProgressView.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/27/21.
//

import SwiftUI

//https://swdevnotes.com/swift/2021/how-to-create-progress-indicator-in-swiftui/
struct CircularProgressView: View
{
    @Binding var Percent: Double
    @State var ForegroundColor: Color = .blue
    @State var BackgroundColor: Color = Color(.systemGray4)
    @State var Width: CGFloat = 24.0
    @State var Height: CGFloat = 24.0
    @State var StrokeThickness: CGFloat = 5.0
    
    var body: some View
    {
        ZStack
        {
            Circle()
                .stroke(BackgroundColor, lineWidth: StrokeThickness)
            Circle()
                .trim(from: 0, to: CGFloat(self.Percent))
                .stroke(ForegroundColor,
                        style: StrokeStyle(lineWidth: StrokeThickness,
                                           lineCap: .round))
        }
        .animation(.linear(duration: 0.15))
        .transition(.slide)
        .rotationEffect(Angle(degrees: -90))
        .frame(width: Width, height: Height)
        .padding()
    }
}

struct CircularProgressView_Previews: PreviewProvider
{
    @State static var Value: Double = 0.61
    static var previews: some View
    {
        VStack
        {
            CircularProgressView(Percent: $Value)
        }
    }
}
