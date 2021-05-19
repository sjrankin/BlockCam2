//
//  BuiltInImageTableEntryView2.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/19/21.
//

import Foundation
import SwiftUI
import Combine

struct BultInImageTableEntryView2: View
{
    @State var ImageName: String
    @State var ImageDescription: String
    @State var Attribution: String
    @State var OverallWidth: CGFloat
    @State var ImageTapped: Bool = false
    @State var AttributionTapped: Bool = false
    
    var body: some View
    {
        HStack
        {
            Image(ImageName)
                .resizable()
                .border(Color.black, width: 0.5)
                .frame(alignment: .center)
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80, alignment: .leading)
            Text(ImageDescription)
                .font(.headline)
            Spacer()
            Button(action:
                    {
                        AttributionTapped.toggle()
                    })
            {
                Image(systemName: "info.circle")
                    .frame(width: 24, height: 24, alignment: .trailing)
                    .padding()
            }
        }
        .alert(isPresented: $AttributionTapped)
        {
            Alert(title: Text("Attribution"),
                  message: Text(Attribution),
                  dismissButton: .default(Text("OK")))
        }
        .frame(width: OverallWidth * 0.95,
               alignment: .leading)
        .background(ImageTapped ? Color(UIColor.systemTeal) : Color.white)
        .padding([.leading, .trailing])
        .onTapGesture
        {
            ImageTapped.toggle()
        }
    }
}

struct BultInImageTableEntryView2_Preview: PreviewProvider
{
    static var previews: some View
    {
        GeometryReader
        {
            Reader in
            VStack
            {
                Text("Samples: \(SampleImages.BuiltInSamples.count)")
                ForEach(0 ..< SampleImages.BuiltInSamples.count, id: \.self)
                {
                    Index in
                    BultInImageTableEntryView2(ImageName: SampleImages.BuiltInSamples[Index].SampleName,
                                               ImageDescription: SampleImages.BuiltInSamples[Index].Title,
                                               Attribution: SampleImages.BuiltInSamples[Index].Attribution,
                                               OverallWidth: Reader.size.width)
                }
            }
        }
    }
}
