//
//  Test_LongDurationView.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 6/3/21.
//

import SwiftUI

struct Test_LongDurationView: View
{
    @State var UICommand: String
    @State var IsVisible: Bool = true
    @State var Width: CGFloat
    @State var Height: CGFloat
    @State var Message: String
    @State var OperationPercent: Double
    @State var Direction: Double = 1.0
    let TestTimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    @State var Updated: Bool = false
    
    var body: some View
    {
        GeometryReader
        {
            Geometry in
            VStack
            {
                SlowMessage(IsVisible: $IsVisible,
                            Message: $Message,
                            Width: Width,
                            Height: Height,
                            OperationPercent: $OperationPercent)
                    .onReceive(TestTimer)
                    {
                        _ in
                        OperationPercent = OperationPercent + (0.01 * Direction)
                        if OperationPercent > 1.0
                        {
                            OperationPercent = 1.0
                            Direction = -1.0
                        }
                        if OperationPercent < 0.0
                        {
                            OperationPercent = 0.0
                            Direction = 1.0
                        }
                    }
            }
            .navigationTitle("Slow Dialog")
        }
    }
}

struct Test_LongDurationView_Previews: PreviewProvider
{
    @State static var UICommand: String = ""
    @State static var Percent: Double = 0.5
    @State static var ShowMessage: Bool = true
    @State static var Message: String = "Test of long duration dialog box."
    
    static var previews: some View
    {
        GeometryReader
        {
            Geometry in
            VStack
            {
                Test_LongDurationView(UICommand: UICommand,
                                      IsVisible: ShowMessage,
                                      Width: Geometry.size.width,
                                      Height: 40,
                                      Message: Message,
                                      OperationPercent: Percent)
            }
        }
    }
}
