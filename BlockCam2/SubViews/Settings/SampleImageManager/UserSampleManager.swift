//
//  UserSampleManager.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/18/21.
//

import SwiftUI

struct UserSampleManager: View
{
    @State var Updated: Bool = false
    @State var ShowImagePicker: Bool = false
    @State var ShowDeleteOneAlert: Bool = false
    @State var ShowDeleteAllAlert: Bool = false
    @State var SampleList: [SampleImageData] = SampleImages.UserDefinedSamples
    @State var SampleListCount: Int = SampleImages.UserDefinedSamples.count
    @Environment(\.presentationMode) var presentionMode: Binding<PresentationMode>
    @State var SelectedIndex: Int = -1
    @State var ShowEditor: Bool = false
    
    var body: some View
    {
        GeometryReader
        {
            Reader in
            ScrollView
            {
                LazyVStack
                {
                    ForEach(0 ..< SampleListCount, id: \.self)
                    {
                        Index in
                        UserImageTableEntry(ImageName: SampleList[Index].SampleName,
                                            ImageDescription: $SampleList[Index].Title,
                                            OverallWidth: Reader.size.width,
                                            SelectedIndex: $SelectedIndex,
                                            ItemIndex: Index)
                    }
                }
            }
            .padding(.top)
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.TitleUpdate))
            {
                Changed in
                print("Received title changed notification: \(Changed)")
                SampleList[SelectedIndex].Title = Changed.userInfo?["Title"] as! String
                print("--> \(SampleList[SelectedIndex].Title)")
                SampleList = SampleImages.UserDefinedSamples
                Updated.toggle()
            }
        }
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarTitle(Text("User Sample Images"))
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
            ToolbarItemGroup(placement: .bottomBar)
            {
                Button(action:
                        {
                            ShowImagePicker = true
                        },
                       label:
                        {
                            VStack
                            {
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 22, height: 22, alignment: .center)
                                    .font(Font.title.weight(.bold))
                                Text("Add")
                                    .font(.custom("Avenir-Light", size: 12))
                                    .padding(.top, -5)
                            }
                        })
                    .padding()
                
                Button(action:
                        {
                            if SelectedIndex > -1
                            {
                                ShowEditor = true
                            }
                        },
                       label:
                        {
                            VStack
                            {
                                Image(systemName: "pencil.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 22, height: 22, alignment: .center)
                                    .font(Font.title.weight(.bold))
                                Text("Edit")
                                    .font(.custom("Avenir-Light", size: 12))
                                    .padding(.top, -5)
                            }
                        })
                    .padding()
                
                Spacer()
                
                Button(action:
                        {
                            print("Refresh")
                             Updated.toggle()
                             SampleList = [SampleImageData]()
                             //                            SampleList = SampleImages.UserDefinedSamples
                             Updated.toggle()
                             //SampleList = SampleImages.UserDefinedSamples
                             //Updated.toggle()
                        },
                       label:
                        {
                            VStack
                            {
                                Image(systemName: "arrow.triangle.2.circlepath.circle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 22, height: 22, alignment: .center)
                                    .font(Font.title.weight(.bold))
                                Text("Refresh")
                                    .font(.custom("Avenir-Light", size: 12))
                                    .padding(.top, -5)
                            }
                        })
                    .padding()
                
                Spacer()
                
                Button(action:
                        {
                            print("Delete image")
                            ShowDeleteOneAlert = true
                        },
                       label:
                        {
                            VStack
                            {
                                Image(systemName: "trash")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 22, height: 22, alignment: .center)
                                    .foregroundColor(.red)
                                    .font(Font.title.weight(.bold))
                                Text("Delete")
                                    .font(.custom("Avenir-Light", size: 12))
                                    .foregroundColor(.red)
                                    .padding(.top, -5)
                            }
                        })
                    .padding()
                    .alert(isPresented: $ShowDeleteOneAlert)
                    {
                        Alert(title: Text("Really Delete?"),
                              message: Text("Do you really want to delete the selected image from BlockCam? The image will not be deleted from the Photo Album."),
                              primaryButton: .destructive(Text("OK"))
                              {
                                print("delete something")
                                SampleListCount = SampleList.count
                              },
                              secondaryButton: .default(Text("Cancel")))
                    }
                
                Button(action:
                        {
                            print("Clear all images")
                            ShowDeleteAllAlert = true
                        },
                       label:
                        {
                            VStack
                            {
                                Image(systemName: "trash.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 22, height: 22, alignment: .center)
                                    .foregroundColor(.red)
                                    .font(Font.title.weight(.bold))
                                Text("Clear All")
                                    .font(.custom("Avenir-Light", size: 12))
                                    .foregroundColor(.red)
                                    .padding(.top, -5)
                            }
                        })
                    .padding()
                    .alert(isPresented: $ShowDeleteAllAlert)
                    {
                        Alert(title: Text("Really Delete All?"),
                              message: Text("Do you really want to delete all of your sample images from BlockCam? This action will note delete your images but only removed them from BlockCam."),
                              primaryButton: .destructive(Text("OK"))
                              {
                                SampleImages.DeleteAllUserSamples()
                                SampleList = SampleImages.UserDefinedSamples
                                SampleListCount = SampleList.count
                                Updated.toggle()
                              },
                              secondaryButton: .default(Text("Cancel")))
                    }
            }
        }
        .sheet(isPresented: $ShowImagePicker)
        {
            AddUserImageView()
            {
                OK in
                if OK
                {
                    SampleList = SampleImages.UserDefinedSamples
                    Updated.toggle()
                }
            }
        }
        .sheet(isPresented: $ShowEditor)
        {
            if SelectedIndex > -1
            {
                EditUserImageView(UserData: SampleImages.UserDefinedSamples[SelectedIndex])
                {
                    OK in
                    if OK
                    {
                        SampleList = SampleImages.UserDefinedSamples
                        Updated.toggle()
                    }
                }
            }
        }
    }
}

struct UserSampleManager_Previews: PreviewProvider
{
    static var previews: some View
    {
        UserSampleManager()
    }
}


