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
    @State var TestValue: Bool = false
    
    var body: some View
    {
        GeometryReader
        {
            Geometry in
            NavigationView
            {
                LazyHStack(alignment: .top)
                {
                    LazyVStack
                    {
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
                        .frame(width: Geometry.size.width * 0.85)
                        
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
                        .frame(width: Geometry.size.width * 0.85)
                        
                        Spacer()
                    }
                }
                .padding([.leading, .trailing], -130)
            }
            .frame(width: Geometry.size.width,
                   height: Geometry.size.height,
                   alignment: .top)
            .navigationBarTitle(Text("Program Settings"))
        }
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider
{
    static var previews: some View
    {
        SettingsView()
    }
}
#endif
