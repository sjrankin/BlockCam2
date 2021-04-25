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
    @Binding var IsHighlighted: Bool
    @Binding var DoRotate: Bool
    
    var body: some View
    {
        Image(systemName: "camera.filters")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 32, height: 32, alignment: .center)
            .foregroundColor(!IsHighlighted ? .black : .yellow)
            .rotationEffect(.degrees(!DoRotate ? 360.0 : 0.0))
            .animation(!DoRotate ? Animation.linear(duration: 10.0)
                        .repeatForever(autoreverses: false) : Animation.default)
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

struct ContentView: View
{
    @State var DidTapCommand: Bool = false
    @State var SelectedFilter: String = ""
    @State var SelectedGroup: String = ""
    @State var ShowFilterList: Bool = false
    @State var FilterButtonPressed: String = ""
    @State var FilterButtonTapped: Bool = true
    @State var IsSelfieCamera: Bool = false
    @State var ShowImageSaved: Bool = false
    @State var ToolHeight: CGFloat = 150
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
                
                let LiveView = LiveViewControllerUI(FilterButtonPressed: $FilterButtonPressed,
                                                    IsSelfieCamera: $IsSelfieCamera)
                LiveView
                    .frame(width: Geometry.size.width, height: TopHeight, alignment: .top)
                    .position(x: Geometry.size.width / 2.0,
                              y: TopHeight / 2.0)
                
                ImageSaved(IsVisible: $ShowImageSaved,
                           Width: Geometry.size.width,
                           Height: Geometry.size.height)
                
                FilterView(Width: Geometry.size.width,
                           Height: Geometry.size.height,
                           ToolHeight: ToolHeight,
                           BottomHeight: BottomHeight, 
                           ToggleHidden: $FilterButtonTapped,
                           SelectedFilter: $SelectedFilter,
                           SelectedGroup: $SelectedGroup,
                           Block: HandleFilterButtonPress)
                
                Group
                {
                    HStack(alignment: .bottom)
                    {
                        Group
                        {
                            Spacer()
                            
                            Button(action:
                                    {
                                        FilterButtonTapped.toggle()
                                    })
                            {
                                FiltersIcon(IsHighlighted: $FilterButtonTapped,
                                            DoRotate: $FilterButtonTapped)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .shadow(radius: 3)
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
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .shadow(radius: 3)
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
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .shadow(radius: 3)
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
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .shadow(radius: 3)
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
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .shadow(radius: 3)
                            
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
    
    func HandleFilterButtonPress(_ Value: String)
    {
        self.FilterButtonPressed = ""
        self.FilterButtonPressed = Value
    }
}

struct ContentView_Previews: PreviewProvider
{
    static var previews: some View
    {
        ContentView()
    }
}
