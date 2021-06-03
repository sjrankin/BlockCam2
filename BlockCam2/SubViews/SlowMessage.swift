//
//  SlowMessage.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/27/21.
//

import Foundation
import SwiftUI

struct SlowMessage: View
{
    @Binding var IsVisible: Bool
    @Binding var Message: String
    @State var Width: CGFloat
    @State var Height: CGFloat
    @Binding var OperationPercent: Double
    var BGGradient = LinearGradient(gradient: Gradient(colors: [Color(UIColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 1.0)),
                                                                Color(UIColor(red: 0.0, green: 0.0, blue: 0.2, alpha: 1.0)),
                                                                Color(UIColor(red: 0.0, green: 0.0, blue: 0.05, alpha: 1.0))]),
                                    startPoint: .top, endPoint: .center)
    
    var body: some View
    {
        HStack
        {
            ZStack
            {
            CircularProgressView(Percent: $OperationPercent,
                                 Width: 48,
                                 Height: 48,
                                 StrokeThickness: 8)
                IndeterminantCircularProgressView(Velocity: 2,
                                                  ForegroundColor: Color(UIColor.systemYellow),
                                                  BackgroundColor: Color.clear,
                                                  Width: 30,
                                                  Height: 30,
                                                  DashArray: [1, 15],
                                                  Direction: -1.0)
                    .frame(width: 30, height: 30)
            }
            
            Text(Message)
                .foregroundColor(.white)
                .font(.custom("Avenir-Heavy", size: 26.0))
                .lineLimit(2)
                .padding(.trailing)
        }
        .background(
            ZStack
            {
                RoundedRectangle(cornerRadius: 10.0)
                    .stroke(Color.white, lineWidth: 5)
                    .shadow(radius: 5)
                RoundedRectangle(cornerRadius: 10.0)
                    .fill(BGGradient)
                    .shadow(radius: 3)
            }
            .shadow(color: .black, radius: 3)
            .frame(width: Width * 0.9, height: 100)
        )
        
        .frame(width: Width * 0.9,
               height: 100.0,
               alignment: .top)
        .position(x: IsVisible ? Width / 2 : -Width / 2,
                  y: 400 / 2)
        .animation(.linear(duration: IsVisible ? 0.2 : 0.15))
        .transition(.slide)
        
    }
}

struct SlowMessagePreviews: PreviewProvider
{
    @State static var Percent: Double = 0.5
    @State static var ShowSlowMessage: Bool = true
    @State static var SlowMessageText: String = "Long duration message, toodle-oo, caribou!"
    
    static var previews: some View
    {
        GeometryReader
        {
            Geometry in
            VStack
            {
                SlowMessage(IsVisible: $ShowSlowMessage,
                            Message: $SlowMessageText,
                            Width: Geometry.size.width,
                            Height: 40,
                            OperationPercent: $Percent)
            }
        }
    }
}
