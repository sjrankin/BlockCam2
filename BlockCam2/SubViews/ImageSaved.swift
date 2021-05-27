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

struct SlowMessage: View
{
    @Binding var IsVisible: Bool
    @Binding var Message: String
    @State var Width: CGFloat
    @State var Height: CGFloat
    var BGGradient = LinearGradient(gradient: Gradient(colors: [Color(UIColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 1.0)),
                                                                Color(UIColor(red: 0.0, green: 0.0, blue: 0.2, alpha: 1.0)),
                                                                Color(UIColor(red: 0.0, green: 0.0, blue: 0.05, alpha: 1.0))]),
                                    startPoint: .top, endPoint: .center)
    
    var body: some View
    {
        HStack
        {
            ProgressView()
                .scaleEffect(1.5, anchor: .center)
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .padding(.trailing)

            Text(Message)
                .foregroundColor(.white)
                .font(.custom("Avenir-Heavy", size: 26.0))
                .lineLimit(2)
                .padding(.leading)
        }
        .background(
            ZStack
            {
                RoundedRectangle(cornerRadius: 10.0)
                    .stroke(Color.blue, lineWidth: 5)
                    .shadow(radius: 5)
                RoundedRectangle(cornerRadius: 10.0)
                    .fill(BGGradient)
                    .shadow(radius: 3)
            }
            .shadow(color: .accentColor, radius: 5)
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

struct MessagePreviews: PreviewProvider
{
    @State static var ShowMessage: Bool = true
    @State static var ShowSlowMessage: Bool = true
    @State static var SlowMessageText: String = "Long duration message, toodle-oo, caribou!"
    @State static var Message: String = "Saving Image"
    
    static var previews: some View
    {
        GeometryReader
        {
            Geometry in
        VStack
        {
            ImageSaved(IsVisible: $ShowMessage,
                       Message: $Message,
                       Width: Geometry.size.width,
                       Height: 40)
            Spacer()
            SlowMessage(IsVisible: $ShowSlowMessage,
                        Message: $SlowMessageText,
                        Width: Geometry.size.width,
                        Height: 40)
        }
        }
    }
}
