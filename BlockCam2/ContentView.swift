//
//  ContentView.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/13/21.
//

import SwiftUI

struct CameraIcon: View
{
    var body: some View
    {
        Image(systemName: "camera")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 32, height: 32, alignment: .center)
            .foregroundColor(.yellow)
    }
}

struct FiltersIcon: View
{
    var body: some View
    {
        Image(systemName: "camera.filters")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 32, height: 32, alignment: .center)
            .foregroundColor(.yellow)
    }
}

struct GearIcon: View
{
    var body: some View
    {
        Image(systemName: "gearshape")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 32, height: 32, alignment: .center)
            .foregroundColor(.yellow)
    }
}

struct SelfieIcon: View
{
    @State var IconName: String = ""
    
    init(_ IconName: String)
    {
        self.IconName = IconName
    }
    
    var body: some View
    {
        Image(systemName: IconName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 32, height: 32, alignment: .center)
            .foregroundColor(.yellow)
    }
}

struct BackCameraIcon: View
{
    var body: some View
    {
        Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 32, height: 32, alignment: .center)
            .foregroundColor(.yellow)
    }
}

struct PhotoLibraryIcon: View
{
    var body: some View
    {
        Image(systemName: "photo.on.rectangle.angled")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 32, height: 32, alignment: .center)
            .foregroundColor(.yellow)
    }
}

struct ImageSaved: View
{
    @State var IsVisible: Bool
    
    init(Visible: Bool)
    {
        IsVisible = Visible
    }
    
    var body: some View
    {
        Text("Image Saved")
            .foregroundColor(.blue)
            .font(.headline).bold()
            .padding()
            .opacity(IsVisible ? 1.0 : 0.0)
            .background(RoundedRectangle(cornerRadius: 10.0)
                            .fill(Color.white)
                            .shadow(radius: 5)
                            .frame(width: 400, height: 50)
                            .opacity(IsVisible ? 1.0 : 0.0))
    }
}

struct ContentView: View
{
    @State var FilterButtonPressed: String = ""
    @State var IsSelfieCamera: Bool = false
    @State var ShowImageSaved: Bool = false
    @State var WhichCamera: String = "arrow.triangle.2.circlepath.camera"
    
    var body: some View
    {
        ZStack
        {
            Color.blue.edgesIgnoringSafeArea(.bottom)
            GeometryReader
            {
                Geometry in
                let BottomHeight: CGFloat = 64.0
                let TopHeight: CGFloat = Geometry.size.height - BottomHeight
                
                LiveViewControllerUI(FilterButtonPressed: $FilterButtonPressed,
                                     IsSelfieCamera: $IsSelfieCamera)
                    .frame(width: Geometry.size.width, height: TopHeight, alignment: .top)
                    .position(x: Geometry.size.width / 2.0,
                              y: TopHeight / 2.0)
                
                ImageSaved(Visible: ShowImageSaved)
                    .frame(width: Geometry.size.width * 0.75, height: 30, alignment: .top)
                    .position(x: Geometry.size.width / 2.0,
                              y: 75.0 / 2.0)
                
                Group
                {
                    HStack(alignment: .bottom)
                    {
                        Group
                        {
                            Spacer()
                            Button(action:
                                    {
                                        self.FilterButtonPressed = ""
                                        self.FilterButtonPressed = "Filters"
                                    }
                            )
                            {
                                FiltersIcon()
                            }.buttonStyle(BorderlessButtonStyle())
                        }
                        
                        Group
                        {
                            Spacer()
                            Button(action:
                                    {
                                        self.FilterButtonPressed = ""
                                        self.FilterButtonPressed = "Album"
                                    }
                            )
                            {
                                PhotoLibraryIcon()
                            }.buttonStyle(BorderlessButtonStyle())
                        }
                        
                        Group
                        {
                            Spacer()
                            Button(action:
                                    {
                                        self.FilterButtonPressed = ""
                                        self.FilterButtonPressed = "Camera"
                                    }
                            )
                            {
                                CameraIcon()
                            }.buttonStyle(BorderlessButtonStyle())
                        }
                        
                        Group
                        {
                            Spacer()
                            Button(action:
                                    {
                                        let CommandString = "Selfie"
                                        self.IsSelfieCamera = !self.IsSelfieCamera
                                        if self.IsSelfieCamera
                                        {
                                            self.WhichCamera = "arrow.triangle.2.circlepath.camera.fill"
                                        }
                                        else
                                        {
                                            self.WhichCamera = "arrow.triangle.2.circlepath.camera"
                                        }
                                        self.FilterButtonPressed = ""
                                        self.FilterButtonPressed = CommandString
                                    })
                            {
                                Image(systemName: WhichCamera)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 32, height: 32, alignment: .center)
                                    .foregroundColor(.yellow)
                            }.buttonStyle(BorderlessButtonStyle())
                        }
                        
                        Group
                        {
                            Spacer()
                            Button(action:
                                    {
                                        self.FilterButtonPressed = ""
                                        self.FilterButtonPressed = "Settings"
                                    }
                            )
                            {
                                GearIcon()
                            }.buttonStyle(BorderlessButtonStyle())
                            Spacer()
                        }
                    }
                    .padding(.bottom, 0.0)
                    .frame(height: BottomHeight, alignment: .center)
                }
                .frame(width: Geometry.size.width,
                       height: BottomHeight)
                .background(Color.red)
                .position(x: Geometry.size.width / 2.0,
                          y: Geometry.size.height - (BottomHeight / 2.0))
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider
{
    static var previews: some View
    {
        ContentView()
    }
}
