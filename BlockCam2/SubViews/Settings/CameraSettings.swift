//
//  CameraSettings.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/17/21.
//

import SwiftUI

struct CameraSettings: View
{
    @Environment(\.presentationMode) var presentionMode: Binding<PresentationMode>
    @State var SaveOriginalImage: Bool = Settings.GetBool(.SaveOriginalImage)
    @State var ShowLiveView: Bool = Settings.GetBool(.UseLiveView)
    
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
                        Text("Save Original")
                            .font(.headline)
                            .frame(width: Geometry.size.width * 0.65,
                                   alignment: .leading)
                        Text("Save the original image along with the processed image. This applies only to pictures taken with your device's camera.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: Geometry.size.width * 0.65,
                                   alignment: .leading)
                    }
                    Toggle("", isOn: $SaveOriginalImage)
                        .frame(width: Geometry.size.width * 0.2)
                        .onChange(of: SaveOriginalImage)
                        {
                            NewValue in
                            Settings.SetBool(.SaveOriginalImage, NewValue)
                        }
                }
                .padding()
                
                Divider()
                    .background(Color.black)
                
                HStack
                {
                    VStack
                    {
                        Text("Live view")
                            .font(.headline)
                            .frame(width: Geometry.size.width * 0.65,
                                   alignment: .leading)
                        Text("Live view uses the currently-selected filter. This will increase battery usage. Turn off to increase reduce battery usage.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: Geometry.size.width * 0.65,
                                   alignment: .leading)
                    }
                    Toggle("", isOn: $ShowLiveView)
                        .frame(width: Geometry.size.width * 0.2)
                        .onChange(of: ShowLiveView)
                    {
                        NewValue in
                        Settings.SetBool(.UseLiveView, NewValue)
                    }
                }
                .padding()
                
                Divider()
                    .background(Color.black)
            }
            .navigationBarTitle(Text("Camera Settings"))
            .navigationBarTitleDisplayMode(.inline)
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
        
    }
    
}

struct CameraSettings_Previews: PreviewProvider
{
    static var previews: some View
    {
        CameraSettings()
    }
}
