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
    @Binding var ButtonCommand: String
    @EnvironmentObject var Changed: ChangedSettings
    @State var Updated: Bool = false
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
                                    Updated.toggle()
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
                        Updated.toggle()
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
                        Updated.toggle()
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
                                        Updated.toggle()
                                    }
                                QuadrantButton(Quadrant: $Quadrant,
                                               ExpectedQuadrant: 2,
                                               ImageAngle: 270.0)
                                    .onTapGesture
                                    {
                                        Quadrant = 2
                                        Settings.SetInt(.MirrorQuadrant, Quadrant)
                                        Updated.toggle()
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
                                        Updated.toggle()
                                    }
                                QuadrantButton(Quadrant: $Quadrant,
                                               ExpectedQuadrant: 3,
                                               ImageAngle: 0.0)
                                    .onTapGesture
                                    {
                                        Quadrant = 3
                                        Settings.SetInt(.MirrorQuadrant, Quadrant)
                                        Updated.toggle()
                                    }
                            }
                        }
                        .padding()
                    }
                    Spacer()
                }
                .padding()
                
                Spacer()
                
                Divider()
                    .background(Color.black)
                SampleImage(UICommand: $ButtonCommand,
                            Filter: .Mirroring2,
                            Updated: $Updated.wrappedValue)
                    .frame(width: 300, height: 300, alignment: .center)
            }
        }
        .onReceive(Changed.$ChangedFilter, perform:
                    {
                        Value in
                        if Value == BuiltInFilters.Mirroring2.rawValue
                        {
                            MirrorLeft = Settings.GetBool(.MirrorLeft)
                            MirrorTop = Settings.GetBool(.MirrorTop)
                            Direction = Settings.GetInt(.MirrorDirection)
                            Quadrant = Settings.GetInt(.MirrorQuadrant)
                            Updated.toggle()
                        }
                    })
    }
    
}

struct MirrorFilterView_Previews: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        MirrorFilter_View(ButtonCommand: $NotUsed, Quadrant: 1)
            .environmentObject(ChangedSettings())
    }
}
