//
//  UserSampleManager.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/18/21.
//

import SwiftUI

struct UserSampleManager: View
{
    @Environment(\.presentationMode) var presentionMode: Binding<PresentationMode>
    
    var body: some View
    {
        GeometryReader
        {
            Reader in
            ScrollView
            {
                LazyVStack
                {
                }
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
                            print("Add new image")
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
                            }
                        })
                    .padding()
                Button(action:
                        {
                            print("Edit existing image")
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
                            }
                        })
                    .padding()
                Spacer()
                Button(action:
                        {
                            print("Delete image")
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
                            }
                        })
                    .padding()
                Button(action:
                        {
                            print("Clear all images")
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
                            }
                        })
                    .padding()
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
