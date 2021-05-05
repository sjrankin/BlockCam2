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
    @State var Updated: Bool = false
    @State var Angle: Double = Double(Settings.GetInt(.KaleidoscopeAngleOfReflection))
    @State var AngleString: String = "\(Settings.GetInt(.KaleidoscopeAngleOfReflection))"
    @State var SegmentCount: Double = Double(Settings.GetInt(.KaleidoscopeSegmentCount))
    @State var SegmentCountString: String = "\(Settings.GetInt(.KaleidoscopeSegmentCount))"
    @State var Options: [FilterOptions: Any] = [.Count: Double(Settings.GetInt(.KaleidoscopeSegmentCount)),
                                                .Angle: Settings.GetInt(.KaleidoscopeAngleOfReflection)]
    
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
                                        Options[.Count] = Int(SegmentCount)
                                    }
                                })
                        TextField("", text: $SegmentCountString,
                                  onCommit:
                                    {
                                        if let Actual = Int(self.SegmentCountString)
                                        {
                                            Settings.SetInt(.KaleidoscopeSegmentCount, Actual)
                                            SegmentCount = Double(Actual)
                                            Options[.Count] = Int(SegmentCount)
                                        }
                                    })
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.custom("Avenir-Black", size: 18.0))
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
                                    Options[.Angle] = Int(Angle)
                                }
                            })
                    TextField("0", text: $AngleString,
                              onCommit:
                                {
                                    if let Actual = Int(self.AngleString)
                                    {
                                        Settings.SetInt(.KaleidoscopeAngleOfReflection, Actual)
                                        Angle = Double(Actual)
                                        Options[.Angle] = Int(Angle)
                                    }
                                })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.custom("Avenir-Black", size: 18.0))
                        .keyboardType(.numbersAndPunctuation)
                }
                .padding()
                }
            Spacer()
            #if true
            SampleImage(Filter: .Kaleidoscope, Updated: $Updated.wrappedValue)
                .frame(width: 300, height: 300, alignment: .center)
            #else
            SampleImage(FilterOptions: $Options, Filter: .Kaleidoscope)
                .frame(width: 300, height: 300, alignment: .center)
            #endif
        }
    }
}

struct KaleidoscopeFilter_Preview: PreviewProvider
{
    static var previews: some View
    {
        KaleidoscopeFilter_View()
    }
}
