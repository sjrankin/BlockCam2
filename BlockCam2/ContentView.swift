//
//  ContentView.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/13/21.
//

import SwiftUI


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
    @State var ShowSettings: Bool = false
    @State var ShowFilterSettings: Bool = false
    
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
                let TopBarHeight: CGFloat = 64
                
                let LiveView = LiveViewControllerUI(FilterButtonPressed: $FilterButtonPressed,
                                                    IsSelfieCamera: $IsSelfieCamera,
                                                    ShowFilterSettings: $ShowFilterSettings,
                                                    ToggleSavedImageNotice: $ShowImageSaved)
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
                
                FilterSettingsView(IsVisible: ShowFilterSettings)
                
                Group
                {
                    HStack(alignment: .top)
                    {
                        Spacer()
                        Group
                        {
                            Button(action:
                                    {
                                        self.FilterButtonPressed = ""
                                        self.FilterButtonPressed = "EditFilter"
                                    })
                            {
                                EditFilterIcon()
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .shadow(color: Color(UIColor.systemTeal), radius: 3)
                            .padding()
                        }
                        Spacer()
                        HStack(alignment: .top)
                        {
                            Group
                            {
                                Button(action:
                                        {
                                            self.FilterButtonPressed = ""
                                            self.FilterButtonPressed = "ShareButton"
                                        })
                                {
                                    SharingIcon()
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                .shadow(color: Color(UIColor.systemTeal), radius: 3)
                                .padding()
                            }
                        }
                        Spacer()
                    }
                }
                .frame(width: Geometry.size.width,
                       height: TopBarHeight)
                .background(Color(UIColor(red: 0.15, green: 0.15, blue: 0.35, alpha: 1.0)))
//                .background(Color.red)
                .position(x: Geometry.size.width / 2.0,
                          y: TopBarHeight / 2.0)
                //y: Geometry.size.height - (BottomHeight / 2.0))
                
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
                                        ShowSettings.toggle()
                                    }
                            )
                            {
                                GearIcon()
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .shadow(radius: 3)
                            .sheet(isPresented: $ShowSettings,
                                   content:
                                    {
                                        ProgramSettingsUI(OptionList: SettingsData)
                                    })
                            
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
