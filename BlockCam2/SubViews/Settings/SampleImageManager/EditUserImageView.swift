//
//  EditUserImageView.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/22/21.
//

import Foundation
import SwiftUI

struct EditUserImageView: View
{
    @State var FileExists: Bool = false
    @State var Updated: Bool = false
    @State var UserData: SampleImageData
    @Environment(\.presentationMode) var presentionMode: Binding<PresentationMode>
    @State var Closure: ((Bool) -> ())? = nil
    
    var body: some View
    {
        GeometryReader
        {
            Geometry in
            VStack(alignment: .leading)
            {
                Text("Description")
                    .font(.headline)
                    .frame(width: Geometry.size.width * 0.9,
                           alignment: .leading)
                    .padding([.top, .leading, .trailing])
                TextField("", text: Binding(
                    get:
                        {
                            self.UserData.Title
                        },
                    set:
                        {
                            NewValue in
                            self.UserData.Title = NewValue
                        }
                ))
                .font(.system(size: 18, weight: .regular, design: .default))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: Geometry.size.width * 0.9,
                       alignment: .leading)
                .padding([.leading, .trailing])
                
                Divider()
                    .background(Color.black)
                
                Spacer()
                
                VStack(alignment: .center)
                {
                    Image(uiImage: UserData.SampleImage!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .border(Color.black, width: 0.5)
                        .frame(alignment: .center)
                }
                .padding()
                
                Divider()
                    .background(Color.black)
                
                HStack
                {
                    Button(action:
                            {
                                SampleImages.EditUserSample(FileName: UserData.SampleName,
                                                            Description: UserData.Title)
                                print("OK clicked")
                                let Info: [AnyHashable: Any] = ["Title": UserData.Title]
                                NotificationCenter.default.post(name: NSNotification.TitleUpdate,
                                                                object: nil,
                                                                userInfo: Info)
                                Closure?(true)
                                self.presentionMode.wrappedValue.dismiss()
                            })
                    {
                        Text("OK")
                            .font(.custom("Avenir-Heavy", size: 20.0))
                    }
                    .alert(isPresented: $FileExists)
                    {
                        Alert(title: Text("Duplicate Image"),
                              message: Text("The image you selected has the same name as an image already in your list. Please select a different image."),
                              dismissButton: .default(Text("OK"))
                        )
                    }
                    Spacer()
                    Button(action:
                            {
                                print("Cancel pressed")
                                Closure?(false)
                                self.presentionMode.wrappedValue.dismiss()
                            })
                    {
                        Text("Cancel")
                            .font(.custom("Avenir-Heavy", size: 20.0))
                    }
                }
                .padding()
            }
        }
    }
}

struct EditUserImageView_Previews: PreviewProvider
{
    static var previews: some View
    {
        EditUserImageView(UserData: SampleImages.UserDefinedSamples[0])
    }
}
