//
//  KuwaharaFilter_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/17/21.
//

import Foundation
import SwiftUI

struct KuwaharaFilter_View: View
{
    @Binding var ButtonCommand: String
    @EnvironmentObject var Changed: ChangedSettings
    @State var CurrentRadius: String = Settings.GetDouble(.KuwaharaRadius, 0.5).RoundedTo(2, PadTo: 2)
    @State var ActualRadius: Double = Settings.GetDouble(.KuwaharaRadius, 0.5).RoundedTo(2)
    @State var Updated: Bool = false
    @State var ApplyTapped: Bool = false
    @State var ProcessingCompleted: Bool = false
    var NonLiveMessage =
"""
Kuwahara is a non-live view filter which means it cannot be used in live mode. For that reason, if you change any settings, you need to tap the Apply button to see the change.
"""
    
    var body: some View
    {
        GeometryReader
        {
            Geometry in
            ScrollView
            {
                HStack
                {
                    Text(NonLiveMessage)
                        .frame(height: 100)
                        .lineLimit(10)
                }
                .padding()
                
                Divider()
                    .background(Color.black)
                
                VStack
                {
                    HStack
                    {
                        VStack(alignment: .leading)
                        {
                            Text("Radius")
                                .frame(width: Geometry.size.width * 0.4,
                                       alignment: .leading)
                            Text("Radius of effect")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(width: Geometry.size.width * 0.4,
                                       alignment: .leading)
                        }
                        .padding()
                        
                        Spacer()
                        
                        VStack
                        {
                            Text(CurrentRadius)
                                .font(Font.system(.body, design: .monospaced).monospacedDigit())
                                .multilineTextAlignment(.trailing)
                            
                            Slider(value: Binding(
                                get:
                                    {
                                        self.ActualRadius
                                    },
                                set:
                                    {
                                        NewValue in
                                        self.ActualRadius = NewValue.RoundedTo(2)
                                        CurrentRadius = ActualRadius.RoundedTo(2, PadTo: 2)
                                        Settings.SetDouble(.KuwaharaRadius, ActualRadius)
                                    }
                            ), in: 0 ... 50.0)
                            .frame(width: Geometry.size.width * 0.4)
                            .padding()
                        }
                    }
                    Divider()
                        .background(Color.black)
                    VStack
                    {
                        Button("Apply")
                        {
                            ApplyTapped.toggle()
                            Updated.toggle()
                        }
                        .font(.headline)
                        ProgressView()
                            .scaleEffect(2.0, anchor: .center)
                            .padding()
                            .foregroundColor(.blue)
                            .shadow(radius: 10)
                            .animation(Animation.linear(duration: ApplyTapped ? 1.0 : 0.0))
                            .opacity(ApplyTapped ? 1.0 : 0.0)
                            .accentColor(.yellow)
                    }
                    Divider()
                        .background(Color.black)
                    
                    SlowSampleImage(UICommand: $ButtonCommand,
                                Filter: .Kuwahara,
                                Updated: $Updated.wrappedValue,
                                Completed: $ProcessingCompleted)
                        .frame(width: 300, height: 300, alignment: .center)
                }
            }
        }
        .onReceive(Changed.$ChangedFilter, perform:
                    {
                        Value in
                        if Value == BuiltInFilters.HueAdjust.rawValue
                        {
                            ActualRadius = Settings.GetDouble(.KuwaharaRadius).RoundedTo(2)
                            CurrentRadius = Settings.GetDouble(.KuwaharaRadius).RoundedTo(2, PadTo: 2)
                            Updated.toggle()
                        }
                    })
    }
}

struct ShadowedProgressViews: View
{
    var body: some View
    {
        VStack
        {
            ProgressView(value: 0.25)
            ProgressView(value: 0.75)
        }
        .progressViewStyle(DarkBlueShadowProgressViewStyle())
    }
}

struct DarkBlueShadowProgressViewStyle: ProgressViewStyle
{
    func makeBody(configuration: Configuration) -> some View
    {
        ProgressView(configuration)
            .shadow(color: Color(red: 0, green: 0, blue: 0.6),
                    radius: 4.0, x: 1.0, y: 2.0)
    }
}

struct KuwaharaFilter_Preview: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        KuwaharaFilter_View(ButtonCommand: $NotUsed)
            .environmentObject(ChangedSettings())
    }
}
