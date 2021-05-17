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
                HStack(alignment: .top)
                {
                    VStack
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
                        
                        Divider()
                            .background(Color.black)
                        
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
                        
                        Spacer()
                    }
                }
                .padding()
            }
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
