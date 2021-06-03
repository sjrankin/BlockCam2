//
//  IndeterminantCircularProgressView.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 6/2/21.
//

import SwiftUI

struct IndeterminantCircularProgressView: View
{
    @State var Velocity: Int
    @State var ForegroundColor: Color = .blue
    @State var BackgroundColor: Color = Color(.systemGray4)
    @State var Width: CGFloat = 24.0
    @State var Height: CGFloat = 24.0
    @State var StrokeThickness: CGFloat = 5.0
    @State var DashArray: [CGFloat] = [5, 5]
    @State var RotationAngle: Double = 0.0
    var AngleIncrements: [Double] = [0.5, 1.0, 2.0]
    let RotateTimer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    var body: some View
    {
        ZStack
        {
            Circle()
                .stroke(BackgroundColor, lineWidth: StrokeThickness)
            Circle()
                .trim(from: 0, to: 1.0)
                .stroke(ForegroundColor,
                        style: StrokeStyle(lineWidth: StrokeThickness,
                                           lineCap: .round,
                                           dash: DashArray))
        }
        .onReceive(RotateTimer)
        {
            _ in
            let Increment = AngleIncrements[Velocity]
            let FinalAngle = RotationAngle + Increment
            RotationAngle = FinalAngle.truncatingRemainder(dividingBy: 360.0)
            //RotationAngle = Double(Int(RotationAngle + 1.0) % 360)
        }
        .animation(.linear(duration: 0.15))
        .transition(.slide)
        .rotationEffect(Angle(degrees: RotationAngle))
        .frame(width: Width, height: Height)
        .padding()
    }
}

struct IndeterminantCircularProgressView_Previews: PreviewProvider
{
    static var previews: some View
    {
        IndeterminantCircularProgressView(Velocity: 1)
    }
}
