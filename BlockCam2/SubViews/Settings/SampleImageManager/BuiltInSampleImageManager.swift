//
//  SampleImageManager.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/17/21.
//

import SwiftUI

struct BuiltInSampleImageManager: View
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
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle(Text("Built-in Sample Images"))
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
            }
        }
    }
}

struct BuiltInSampleImageManager_Previews: PreviewProvider
{
    static var previews: some View
    {
        BuiltInSampleImageManager()
    }
}
