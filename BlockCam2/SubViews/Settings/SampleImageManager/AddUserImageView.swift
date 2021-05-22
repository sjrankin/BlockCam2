//
//  AddUserImageView.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/20/21.
//

import SwiftUI

struct AddUserImageView: View
{
    @State var FileExists: Bool = false
    @State var Updated: Bool = false
    @State var OpenAlbum: Bool = false
    @State var Description: String = "Description of your sample image"
    @State var SelectedImageName: String? = SampleImages.BuiltInSamples[0].SampleName
    @State var SelectedImage: UIImage? = UIImage(named: SampleImages.CurrentSample.SampleName)!
    @State var SelectedImageURL: URL? = nil
    @Environment(\.presentationMode) var presentionMode: Binding<PresentationMode>
    
    init(_ Block: ((Bool) -> ())? = nil)
    {
        Closure = Block
    }
    
    var Closure: ((Bool) -> ())? = nil
    
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
                            self.Description
                        },
                    set:
                        {
                            NewValue in
                            self.Description = NewValue
                        }
                ))
                .font(.system(size: 18, weight: .regular, design: .default))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: Geometry.size.width * 0.9,
                       alignment: .leading)
                .padding([.leading, .trailing])
                
                Divider()
                    .background(Color.black)
                
                Button(action:
                        {
                                OpenAlbum = true
                        }
                )
                {
                    Text("Select from Photo Album")
                        .font(.headline)
                }
                .padding()
                .sheet(isPresented: $OpenAlbum, onDismiss:
                        {
                        })
                {
                    ImagePicker(SelectedImage: $SelectedImage,
                                SelectedImageName: $SelectedImageName,
                                SelectedImageURL: $SelectedImageURL)
                }
                
                Divider()
                    .background(Color.black)
                
                Spacer()
                
                VStack(alignment: .center)
                {
                    Image(uiImage: SelectedImage!)
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
                                print("OK clicked")
                                guard let ImageToSave = SelectedImage,
                                      let NameToUse = SelectedImageName else
                                {
                                    Debug.Print("Tried to save with no image and name.")
                                    return
                                }
                                if SampleImages.FileInUserList(NameToUse)
                                {
                                    print("Found \(NameToUse) in existing list")
                                    FileExists = true
                                }
                                else
                                {
                                    SampleImages.AddUserSample(FileName: NameToUse,
                                                               Description: Description,
                                                               Image: ImageToSave)
                                }
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

struct AddUserImageView_Previews: PreviewProvider
{
    static var previews: some View
    {
        AddUserImageView()
    }
}
