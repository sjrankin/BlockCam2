//
//  UserImageTableEntry.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/18/21.
//

import SwiftUI
import Combine

struct UserImageTableEntry: View
{
    @State var ImageName: String
    @State var ImageDescription: String
    @State var OverallWidth: CGFloat
    @State var ImageTapped: Bool = false
    @State var SelectedItem: Bool = false
    @State var TappedItem: String = ""
    @Binding var SelectedIndex: Int
    @State var ItemIndex: Int
    
    var body: some View
    {
        HStack
        {
            Image(uiImage: FileIO.LoadImage(SampleImages.URLForSample(Name: ImageName))!) 
                .resizable()
                .border(Color.black, width: 0.5)
                .frame(alignment: .center)
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80, alignment: .leading)
                .padding([.leading])
            Text(ImageDescription)
                .font(.headline)
                .shadow(radius: 3)
            Spacer()
            Button(action:
                    {
                        print("show info for \(ImageName)")
                    })
            {
                Image(systemName: "info.circle")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            .frame(alignment: .trailing)
            .padding()
            .onTapGesture
            {
                print("show info for \(ImageName)")
            }
        }
        .frame(width: OverallWidth * 0.95,
               alignment: .leading)
        .background(ItemIndex == SelectedIndex ? Color.yellow : Color.white)
        //.background(ImageTapped ? Color.yellow : Color.white)
        .padding([.leading, .trailing])
        .onTapGesture
        {
            TappedItem = ImageName
            ImageTapped.toggle()
            print("\(ImageName) tapped")
            SelectedIndex = ItemIndex
        }
    }
}

struct ItemState
{
    var id: String
    var WasTapped: Bool
    var ItemName: String
    var IsSelected: Bool
    var TappedName: String
}

struct UserImageTableEntryView_Preview: PreviewProvider
{
    @State static var Items: [ItemState] =
    [
        ItemState(id: "Sample1", WasTapped: false, ItemName: "Sample1", IsSelected: false, TappedName: ""),
        ItemState(id: "Sample2", WasTapped: false, ItemName: "Sample2", IsSelected: false, TappedName: ""),
        ItemState(id: "Sample3", WasTapped: false, ItemName: "Sample3", IsSelected: false, TappedName: ""),
        ItemState(id: "Sample4", WasTapped: false, ItemName: "Sample4", IsSelected: false, TappedName: ""),
    ]
    
    @State static var SelectedIndex: Int = -1
    
    static var previews: some View
    {
        GeometryReader
        {
            Reader in
            LazyVStack
            {
                ForEach(0 ..< Items.count, id: \.self)
                {
                    Index in
                    UserImageTableEntry(ImageName: Items[Index].ItemName,
                                        ImageDescription: SampleImages.GetCurrentSampleImageName(From: Items[Index].ItemName),
                                        OverallWidth: Reader.size.width,
                                        TappedItem: Items[Index].TappedName,
                                        SelectedIndex: $SelectedIndex,
                                        ItemIndex: Index)
                    Divider()
                        .background(Color.black)
                }
            }
        }
    }
}
