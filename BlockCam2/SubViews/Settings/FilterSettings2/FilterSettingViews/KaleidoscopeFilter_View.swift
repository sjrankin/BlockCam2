//
//  KaleidoscopeFilter_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/30/21.
//

import Foundation
import SwiftUI

struct KaleidoscopeFilter_View: View
{
    @State var Angle: Double = Double(Settings.GetInt(.KaleidoscopeAngleOfReflection))
    @State var AngleString: String = "\(Settings.GetInt(.KaleidoscopeAngleOfReflection))"
    @State var SegmentCount: Double = Double(Settings.GetInt(.KaleidoscopeSegmentCount))
    @State var SegmentCountString: String = "\(Settings.GetInt(.KaleidoscopeSegmentCount))"
    
    var body: some View
    {
        ScrollView
        {
            HStack
            {
                    VStack(alignment: .leading)
                    {
                        Text("Segments")
                        Text("Number of segments in the kaleidoscope")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    
                    Spacer()
                    
                    VStack
                    {
                        Slider(value: $SegmentCount, in: 2 ... 40,
                               onEditingChanged:
                                {
                                    Editing in
                                    if !Editing
                                    {
                                        SegmentCountString = "\(Int(SegmentCount))"
                                        Settings.SetInt(.KaleidoscopeSegmentCount, Int(SegmentCount))
                                    }
                                })
                            //.frame(width: Geometry.size.width * 0.35)
                        TextField("2", text: $SegmentCountString,
                                  onCommit:
                                    {
                                        if let Actual = Int(self.SegmentCountString)
                                        {
                                            Settings.SetInt(.KaleidoscopeSegmentCount, Actual)
                                            SegmentCount = Double(Actual)
                                        }
                                    })
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.custom("Avenir-Black", size: 18.0))
                            //.frame(width: Geometry.size.width * 0.35)
                            .keyboardType(.numbersAndPunctuation)
                    }
                    .padding()
                }

            HStack
            {
                VStack(alignment: .leading)
                {
                    Text("Angle")
                    Text("Angle of reflection")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
                Spacer()
                VStack
                {
                    Slider(value: $Angle, in: 0 ... 359,
                           onEditingChanged:
                            {
                                Editing in
                                if !Editing
                                {
                                    AngleString = "\(Int(Angle))"
                                    Settings.SetInt(.KaleidoscopeAngleOfReflection, Int(Angle))
                                }
                            })
                        //.frame(width: Geometry.size.width * 0.38)
                    TextField("0", text: $AngleString,
                              onCommit:
                                {
                                    if let Actual = Int(self.AngleString)
                                    {
                                        Settings.SetInt(.KaleidoscopeAngleOfReflection, Actual)
                                        Angle = Double(Actual)
                                    }
                                })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.custom("Avenir-Black", size: 18.0))
                        //.frame(width: Geometry.size.width * 0.35)
                        .keyboardType(.numbersAndPunctuation)
                }
                //.frame(width: Geometry.size.width * 0.38)
                .padding()
                }

        }
    }
}
