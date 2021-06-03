//
//  Test_CircularProgressView.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 6/2/21.
//

import SwiftUI

struct Test_CircularProgressView: View
{
    @State var CircleValue: Double = 0.0
    @State var CircleValueDirection: Double = 1.0
    let TestTimer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    var body: some View
    {
        VStack(alignment: .center)
        {
            Spacer()
            
            CircularProgressView(Percent: $CircleValue,
                                 ForegroundColor: Color(UIColor.systemYellow),
                                 BackgroundColor: Color(UIColor.blue),
                                 Width: 96,
                                 Height: 96,
                                 StrokeThickness: 20)
                .onReceive(TestTimer)
                {
                    _ in
                    CircleValue = CircleValue + (0.01 * CircleValueDirection)
                    if CircleValue > 1.0
                    {
                        CircleValue = 1.0
                        CircleValueDirection = -1.0
                    }
                    if CircleValue < 0.0
                    {
                        CircleValue = 0.0
                        CircleValueDirection = 1.0
                    }
                }
            
            Spacer()
            
            IndeterminantCircularProgressView(Velocity: 2,
                                              ForegroundColor: Color(UIColor.blue), 
                                              BackgroundColor: Color(UIColor.systemYellow),
                                              Width: 96,
                                              Height: 96,
                                              StrokeThickness: 20,
                                              DashArray: [1, 29])
            
            Spacer()
        }
        .navigationTitle("Circular Progress")
    }
}

struct Test_CircularProgressView_Previews: PreviewProvider
{
    static var previews: some View
    {
        Test_CircularProgressView()
    }
}
