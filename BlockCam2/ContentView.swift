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
    @State var SelectedFilter: String = Settings.GetString(.CurrentFilter, "Passthrough")
    @State var SelectedGroup: String = Settings.GetString(.CurrentGroup, " Reset ")
    @State var ShowFilterList: Bool = false
    @State var FilterButtonPressed: String = ""
    @State var FilterButtonTapped: Bool = true
    @State var IsSelfieCamera: Bool = false
    @State var ShowShortMessage: Bool = false
    @State var ShortMessage: String = ""
    @State var ToolHeight: CGFloat = 150
    @State var WhichCamera: String = "arrow.triangle.2.circlepath.camera"
    @State var ShowSettings: Bool = false
    @State var ShowFilterSettings: Bool = false
    @State var FilterSettingsVisible: Bool = false
    @State var ShowImageControls: Bool = false
    
    var body: some View
    {
        ZStack
        {
            Color.black.edgesIgnoringSafeArea(.bottom)
            GeometryReader
            {
                Geometry in
                let BottomHeight: CGFloat = 64.0
                let TopHeight: CGFloat = Geometry.size.height - BottomHeight
                let TopBarHeight: CGFloat = 64
                
                LiveViewControllerUI(FilterButtonPressed: $FilterButtonPressed,
                                     IsSelfieCamera: $IsSelfieCamera,
                                     ShowFilterSettings: $ShowFilterSettings,
                                     ShowShortMessageView: $ShowShortMessage,
                                     ShortMessage: $ShortMessage)
                    .frame(width: Geometry.size.width, height: TopHeight, alignment: .top)
                    .position(x: Geometry.size.width / 2.0,
                              y: TopHeight / 2.0)
                
                ImageSaved(IsVisible: $ShowShortMessage,
                           Message: $ShortMessage,
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
                    ZStack(alignment: .top)
                    {
                        HStack(alignment: .top)
                        {
                            Spacer()
                            Group
                            {
                                Button(action:
                                        {
                                            self.FilterSettingsVisible.toggle()
                                        }
                                )
                                {
                                    EditFilterIcon()
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                .shadow(radius: 3)
                                .padding()
                            }
                            .sheet(isPresented: $FilterSettingsVisible)
                            {
                                FilterViewServer(IsVisible: $FilterSettingsVisible)
                            }
                            Spacer()
                            Group
                            {
                                Button(action:
                                        {
                                            self.ShowImageControls.toggle()
                                            self.FilterButtonPressed = ""
                                            self.FilterButtonPressed = "ShareButton"
                                        })
                                {
                                    SharingIcon()
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                .shadow(radius: 3)
                                .padding()
                            }
                            Spacer()
                            Group
                            {
                                Button(action:
                                        {
                                            self.ShowShortMessage.toggle()
                                        })
                                {
                                ButtonIcon(ImageName: "livephoto",
                                           Foreground: Color.yellow,
                                           ShadowRadius: 3)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                .padding()
                            }
                            Spacer()
                            Group
                            {
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
                                .padding()
                                .sheet(isPresented: $ShowSettings,
                                       content:
                                        {
                                            ProgramSettingsUI(OptionList: SettingsData)
                                        })
                                
                                Spacer()
                            }
                        }
                    }
                    .frame(width: Geometry.size.width,
                           height: TopBarHeight)
                    .background(Color.red)
                    .position(x: Geometry.size.width / 2.0,
                              y: (TopBarHeight) / 2.0)
                    
                    HStack(alignment: .top)
                    {
                        Group
                        {
                            Spacer()
                            Button(action:
                                    {
                                        
                                    })
                            {
                                CropButtonIcon()
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .shadow(radius: 3)
                            .padding()
                        }
                        
                        Group
                        {
                            Spacer()
                            Button(action:
                                    {
                                        
                                    })
                            {
                                PinButtonIcon()
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .shadow(radius: 3)
                            .padding()
                        }
                        
                        Group
                        {
                            Spacer()
                            Button(action:
                                    {
                                        ShowImageControls.toggle()
                                    })
                            {
                                CloseButtonIcon()
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .shadow(radius: 3)
                            .padding()
                        }
                    }
                    .frame(width: Geometry.size.width,
                           height: TopBarHeight)
                    .background(Color.yellow)
                    .position(x: ShowImageControls ? Geometry.size.width / 2.0 : (Geometry.size.width) * 2,
                              y: (TopBarHeight) / 2.0)
                    .animation(.linear(duration: ShowImageControls ? 0.1 : 0.2))
                    .transition(.slide)
                }
                
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
                                        self.ShortMessage = "Saving Image"
                                        self.ShowShortMessage = true
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
