//
//  OtherSampleImageOptions.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/17/21.
//

import SwiftUI

struct OtherSampleImageOptions: View
{
    @Environment(\.presentationMode) var presentionMode: Binding<PresentationMode>
    @State var UseLatestBlockCamImage: Bool = Settings.GetBool(.UseLatestBlockCamImage)
    @State var UseMostRecentImage: Bool = Settings.GetBool(.UseLatestBlockCamImage)
    @State var OnlyUserSamples: Bool = Settings.GetBool(.ShowUserSamplesOnlyIfAvailable)
    @State var ShowPrivacyAlert: Bool = false
    
    func EnableLastTaken()
    {
        UseMostRecentImage = true
        UseLatestBlockCamImage = false
        Settings.SetBool(.UseMostRecentImage, true)
        Settings.SetBool(.UseLatestBlockCamImage, false)
    }
    
    func DisableLastTaken()
    {
        UseMostRecentImage = false
        Settings.SetBool(.UseMostRecentImage, false)
    }
    
    var body: some View
    {
        GeometryReader
        {
            Geometry in
            VStack(alignment: .leading)
            {
                HStack
                {
                    VStack
                    {
                        Text("Latest BlockCam Image")
                            .font(.headline)
                            .frame(width: Geometry.size.width * 0.7,
                                   alignment: .leading)
                        Text("Use the most recently taken image with BlockCam - BlockCam will cache the most recently taken image")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: Geometry.size.width * 0.7,
                                   alignment: .leading)
                    }
                    Toggle("", isOn: $UseLatestBlockCamImage)
                        .frame(width: Geometry.size.width * 0.2)
                        .onChange(of: UseLatestBlockCamImage)
                        {
                            NewValue in
                            if NewValue
                            {
                                UseMostRecentImage = false
                                Settings.SetBool(.UseLatestBlockCamImage, true)
                                Settings.SetBool(.UseMostRecentImage, false)
                            }
                        }
                }
                
                Divider()
                    .background(Color.black)
                
                HStack
                {
                    VStack
                    {
                        Text("Last Taken")
                            .font(.headline)
                            .frame(width: Geometry.size.width * 0.7,
                                   alignment: .leading)
                        Text("Use the most recently taken image with with your device. The image is always retrieved when you start the program and used only with your permission. BlockCam does not store the image or use it for any purpose other than as a sample image.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: Geometry.size.width * 0.7,
                                   alignment: .leading)
                    }
                    Toggle("", isOn: $UseMostRecentImage)
                        .frame(width: Geometry.size.width * 0.2)
                        .onChange(of: UseMostRecentImage)
                        {
                            NewValue in
                            ShowPrivacyAlert = NewValue
                        }
                        .alert(isPresented: $ShowPrivacyAlert)
                        {
                            Alert(title: Text("Privacy Warning"),
                                  message: Text("If enabled, BlockCam will use the most recent image you have taken as the sample image regardless of the content."),
                                  primaryButton: .default(
                                    Text("Cancel"),
                                    action: DisableLastTaken),
                                  secondaryButton: .destructive(
                                    Text("OK"),
                                    action: EnableLastTaken
                                  ))
                        }
                }
                
                Divider()
                    .background(Color.black)
                
                HStack
                {
                    VStack
                    {
                        Text("Only User Samples")
                            .font(.headline)
                            .frame(width: Geometry.size.width * 0.7,
                                   alignment: .leading)
                        Text("Use only your user sample images, not the built-in samples. Has no effect if no user samples are available.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: Geometry.size.width * 0.7,
                                   alignment: .leading)
                    }
                    Toggle("", isOn: $OnlyUserSamples)
                        .frame(width: Geometry.size.width * 0.2)
                        .onChange(of: OnlyUserSamples)
                        {
                            NewValue in
                            OnlyUserSamples = NewValue
                            Settings.SetBool(.ShowUserSamplesOnlyIfAvailable, OnlyUserSamples)
                        }
                }
                
                Divider()
                    .background(Color.black)
                
                Text("These options are mutually exclusive and should be used with caution as BlockCam will use the most recent image regardless of the contents.")
                
                Divider()
                    .background(Color.black)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle(Text("Other Settings"))
            .toolbar
            {
                ToolbarItem(placement: .navigationBarTrailing)
                {
                    Button(action:
                            {
                                self.presentionMode.wrappedValue.dismiss()
                            }
                    )
                    {
                        Image(systemName: "xmark.circle.fill")
                    }
                }
            }
        }
        .padding()
    }
}

struct OtherSampleImageOptions_Previews: PreviewProvider
{
    static var previews: some View
    {
        OtherSampleImageOptions()
    }
}
