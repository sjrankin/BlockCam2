//
//  MirrorFilter_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/1/21.
//

import Foundation
import SwiftUI

struct MirrorFilter_View: View
{
    @State var MirrorLeft: Bool = Settings.GetBool(.MirrorLeft)
    @State var MirrorTop: Bool = Settings.GetBool(.MirrorTop)
    @State var Direction: Int = Settings.GetInt(.MirrorDirection)
    @State var Quadrant: Int = Settings.GetInt(.MirrorQuadrant)
    
    var body: some View
    {
        GeometryReader
        {
            Geometry in
            ScrollView
            {
                VStack(alignment: .leading)
                {
                    Text("Mirroring")
                        .padding(.trailing)
                    Text("Select which part of the image to mirror")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.trailing)
                    
                    Picker(selection: $Direction, label: Text("Mirror"), content: {
                        Text("Horizontally").tag(0)
                        Text("Vertically").tag(1)
                        Text("Quadrant").tag(2)
                    })
                    .onChange(of: Direction, perform:
                                {
                                    value in
                                    Settings.SetInt(.MirrorDirection, value)
                                }
                    )
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    Spacer()
                }
                .padding()
                
                HStack
                {
                    VStack(alignment: .leading)
                    {
                        Text("Horizontal Mirroring")
                        Text("Select the horizontal side to mirror")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Toggle(isOn: $MirrorLeft)
                    {
                        Text("Left side")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .onChange(of: MirrorLeft)
                    {
                        Value in
                        Settings.SetBool(.MirrorLeft, Value)
                    }
                }
                .padding()
                
                HStack
                {
                    VStack(alignment: .leading)
                    {
                        Text("Vertical Mirroring")
                        Text("Select the vertical side to mirror")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Toggle(isOn: $MirrorTop)
                    {
                        Text("Top side")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .onChange(of: MirrorTop)
                    {
                        Value in
                        Settings.SetBool(.MirrorTop, Value)
                    }
                }
                .padding()
                
                HStack()
                {
                VStack(alignment: .leading)
                {
                    Text("Quadrant")
                    Text("Select which quadrant of the image to mirror")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    VStack
                    {
                        HStack
                        {
                            QuadrantButton(Quadrant: $Quadrant,
                                           ExpectedQuadrant: 1,
                                           ImageAngle: 180.0)
                                .onTapGesture
                                {
                                    Quadrant = 1
                                    Settings.SetInt(.MirrorQuadrant, Quadrant)
                                }
                            QuadrantButton(Quadrant: $Quadrant,
                                           ExpectedQuadrant: 2,
                                           ImageAngle: 270.0)
                                .onTapGesture
                                {
                                    Quadrant = 2
                                    Settings.SetInt(.MirrorQuadrant, Quadrant)
                                }
                        }
                        HStack
                        {
                            QuadrantButton(Quadrant: $Quadrant,
                                           ExpectedQuadrant: 4,
                                           ImageAngle: 90.0)
                                .onTapGesture
                                {
                                    Quadrant = 4
                                    Settings.SetInt(.MirrorQuadrant, Quadrant)
                                }
                            QuadrantButton(Quadrant: $Quadrant,
                                           ExpectedQuadrant: 3,
                                           ImageAngle: 0.0)
                                .onTapGesture
                                {
                                    Quadrant = 3
                                    Settings.SetInt(.MirrorQuadrant, Quadrant)
                                }
                        }
                    }
                    .padding()
                }
                    Spacer()
                }
                .padding()
                
                Spacer()
            }
        }
    }
}

struct MirrorFilterView_Previews: PreviewProvider
{
    static var previews: some View
    {
        MirrorFilter_View(Quadrant: 1)
    }
}
