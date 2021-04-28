//
//  SettingsView.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/27/21.
//

import SwiftUI

struct SettingsView: View
{
    @ObservedObject var Storage = SettingsUI()
    
    var body: some View
    {
        GeometryReader
        {
            Geometry in
            NavigationView
            {
                VStack()
                {
                    Toggle(isOn: self.$Storage.ShowAudioWaveform)
                    {
                        VStack(alignment: .leading)
                        {
                            Text("Show waveform")
                            Text("Show the audio waveform")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding([.leading, .trailing])
                    
                    Toggle(isOn: self.$Storage.SaveOriginalImage)
                    {
                        VStack(alignment: .leading)
                        {
                            Text("Save original")
                            Text("Save original image with filtered image")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding([.leading, .trailing])
                    
                    Spacer()
                }
                .position(x: Geometry.size.width / 2,
                          y: 150.0)
            }
            .frame(width: Geometry.size.width, height: Geometry.size.height)
            .navigationBarTitle(Text("Program Settings"))
        }
    }
}
