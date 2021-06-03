//
//  Test_3DProcessingView.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 6/1/21.
//

import SwiftUI

struct Test_3DProcessingView: View
{
    @State var UICommand: String = ""
    @State var ShowTest: Bool = true
    @State var MainPercent: Double = 0.0
    @State var Direction: Double = 1.0
    @State var SubDirection: Double = 1.0
    let SubTimer = Timer.publish(every: 0.06, on: .main, in: .common).autoconnect()
    let TestTimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    @State var Updated: Bool = false
    @State var Title: String = "3D Processing"
    @State var Message: String = "Please wait - 3D processing takes time."
    @State var SubPercent: Double = 0.0
    
    var body: some View
    {
        GeometryReader
        {
            Geometry in
            VStack
            {
                Processing3DView(ButtonCommand: $UICommand,
                                 IsVisible: $ShowTest,
                                 Title: $Title,
                                 Message: $Message,
                                 Percent: $MainPercent,
                                 SubPercent: $SubPercent,
                                 TotalWidth: Geometry.size.width)
                    .onReceive(TestTimer)
                    {
                        _ in
                        MainPercent = MainPercent + (Direction * 0.1)
                        if MainPercent > 1.0
                        {
                            MainPercent = 1.0
                            Direction = -1.0
                        }
                        if MainPercent < 0.0
                        {
                            MainPercent = 0.0
                            Direction = 1.0
                        }
                        Updated.toggle()
                    }
                    .onReceive(SubTimer)
                    {
                        _ in
                        SubPercent = SubPercent + (SubDirection * 0.1)
                        if SubPercent > 1.0
                        {
                            SubPercent = 1.0
                            SubDirection = -1.0
                        }
                        if SubPercent < 0.0
                        {
                            SubPercent = 0.0
                            SubDirection = 1.0
                        }
                        Updated.toggle()
                    }
                    .onChange(of: ShowTest)
                    {
                        NewValue in
                        self.ShowTest = NewValue
                        if !self.ShowTest
                        {
                            print("\(UICommand)")
                        }
                    }
                
                HStack
                {
                    Button(action:
                            {
                                self.ShowTest = true
                            },
                           label:
                            {
                                Text("Show")
                                    .font(.headline)
                            })
                        .padding()
                    Button(action:
                            {
                                self.ShowTest = false
                            },
                           label:
                            {
                                Text("Hide")
                                    .font(.headline)
                            })
                        .padding()
                }
                Spacer()
            }
            .navigationTitle("3D Dialog")
        }
    }
}

struct Test_3DProcessingView_Previews: PreviewProvider
{
    static var previews: some View
    {
        Test_3DProcessingView()
    }
}
