//
//  Processing3DView.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 6/1/21.
//

import SwiftUI

struct Processing3DView: View
{
    @Binding var ButtonCommand: String
    @Binding var IsVisible: Bool
    @Binding var Title: String
    @Binding var Message: String
    @Binding var Percent: Double
    @Binding var SubPercent: Double
    @State var TotalWidth: CGFloat
    var BGColor: Color = Color(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0))
    
    var body: some View
    {
        GeometryReader
        {
            Geometry in
            VStack(alignment: .center)
            {
                HStack
                {
                    VStack
                    {
                    CircularProgressView(Percent: $Percent,
                                         ForegroundColor: .white,
                                         BackgroundColor: Color(UIColor.systemTeal),
                                         Width: 32,
                                         Height: 32,
                                         StrokeThickness: 10)
                        .frame(alignment: .leading)
                        Text("Overall")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .padding(.top, -15)
                    }
                    VStack(alignment: .leading)
                    {
                        Text(Title)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(Message)
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .lineLimit(3)
                            .fixedSize(horizontal: false,
                                       vertical: true)
                    }
                }
                Divider()
                    .background(Color(UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)))
                HStack
                {
                    Text("Task")
                        .font(.footnote)
                        .foregroundColor(.gray)
                ProgressView(value: SubPercent)
                    .progressViewStyle(LinearProgressViewStyle(tint: .white))
                    .frame(width: Geometry.size.width * 0.6)
                }
                .frame(alignment: .center)
                VStack(alignment: .center)
                {
                    Button(action:
                            {
                                IsVisible = false
                                ButtonCommand = UICommands.Cancel3DProcessing.rawValue
                            },
                           label: {
                            Text("Cancel")
                                .font(.custom("Avenir-Heavy", size: 20))
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .frame(alignment: .center)
                           })
                }
            }
            .padding([.leading, .trailing])
            .background(
                ZStack
                {
                    RoundedRectangle(cornerRadius: 10.0)
                        .stroke(Color.white, lineWidth: 5)
                        .shadow(radius: 5)
                    RoundedRectangle(cornerRadius: 10.0)
                        .fill(BGColor)
                        .shadow(radius: 3)
                }
            )
            .frame(width: TotalWidth * 0.8,
                   height: 200)
            .position(x: IsVisible ? TotalWidth / 2 : -TotalWidth / 2,
                      y: 400 / 2)
            .animation(.interpolatingSpring(stiffness: 550,
                                            damping: 25,
                                            initialVelocity: 5))
            .transition(.slide)
        }
    }
}

struct Processing3DView_Previews: PreviewProvider
{
    @State static var ForCancel: String = ""
    @State static var ShowTest: Bool = true
    @State static var TestTitle: String = "Please Wait"
    @State static var TestMessage: String = "Processing your image in 3D. This will take some time."
    @State static var Percent: Double = 0.5
    @State static var SubPercent: Double = 0.75
    
    static var previews: some View
    {
        GeometryReader
        {
            Geometry in
            VStack
            {
                Processing3DView(ButtonCommand: $ForCancel,
                                 IsVisible: $ShowTest,
                                 Title: $TestTitle,
                                 Message: $TestMessage,
                                 Percent: $Percent,
                                 SubPercent: $SubPercent,
                                 TotalWidth: Geometry.size.width)
                    .padding()
                Spacer()
                Button(action:
                        {
                            ShowTest = false
                        },
                       label:
                        {
                            Text($ShowTest.wrappedValue ? "Hide Test" : "Show Test")
                                .font(.headline)
                        })
                    .padding()
            }
        }
    }
}
