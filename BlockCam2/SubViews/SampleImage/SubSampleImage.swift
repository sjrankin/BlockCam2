//
//  SubSampleImage.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/5/21.
//

import Foundation
import SwiftUI

struct SubSampleImage: View
{
    @State var Key: SettingKeys
    @Binding var UICommand: String
    @Binding var ImageName: String
    @Binding var Updated: Bool
    @Binding var ImageTitle: String
    
    var body: some View
    {
        VStack
        {
            //Text(SampleImages.GetCurrentSubSampleImageName(From: $ImageName.wrappedValue))
            Text(ImageTitle)
                .frame(alignment: .center)
                .font(.subheadline)
                .foregroundColor(.gray)
            Image(uiImage: UIImage(named: SampleImages.GetSubSampleImageName(At: Key))!)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .background(Color.black)
                .border(Color.black, width: 0.5)
                .frame(alignment: .center)
                .gesture(
                    DragGesture(minimumDistance: 3, coordinateSpace: .local)
                        .onEnded(
                            {
                                value in
                                if value.translation.width < 0
                                {
                                    //swiped left
                                    ImageName = SampleImages.IncrementSubSampleImageName(At: Key)
                                    Updated.toggle()
                                    ImageTitle = SampleImages.GetCurrentSubSampleImageTitle(At: Key)
                                    print("ImageTitle=\(ImageTitle)")
                                }
                                if value.translation.width > 0
                                {
                                    //swiped right
                                    ImageName = SampleImages.DecrementSubSampleImageName(At: Key)
                                    Updated.toggle()
                                    ImageTitle = SampleImages.GetCurrentSubSampleImageTitle(At: Key)
                                    print("ImageTitle=\(ImageTitle)")
                                }
                            })
                )
        }
    }
}

struct SubSampleImage_Preview: PreviewProvider
{
    @State static var NotUsed: String = ""
    @State static var SampleName = "Sapporo2048x2014"
    @State static var ImageTitle = "Sapporo"
    @State static var Updated: Bool = false
    
    static var previews: some View
    {
        SubSampleImage(Key: .SubSampleScratchKey,
                       UICommand: $NotUsed,
                       ImageName: $SampleName,
                       Updated: $Updated,
                       ImageTitle: $ImageTitle)
    }
}
