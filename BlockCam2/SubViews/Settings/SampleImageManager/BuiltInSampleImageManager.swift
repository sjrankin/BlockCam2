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
    @State  var Sample1Enabled: Bool = true
    @State  var Sample2Enabled: Bool = true
    @State  var Sample3Enabled: Bool = true
    @State  var Sample4Enabled: Bool = true
    @State  var Sample5Enabled: Bool = true
    @State  var Sample6Enabled: Bool = true
    @State  var Sample7Enabled: Bool = true
    @State  var Sample8Enabled: Bool = true
    
    var body: some View
    {
        GeometryReader
        {
            Reader in
            ScrollView
            {
            LazyVStack
            {
                Group
                {
                    BultInImageTableEntryView(ImageName: "Sample1",
                                              ImageDescription: "Sample 1",
                                              OverallWidth: Reader.size.width,
                                              ImageIsEnabled: Sample1Enabled,
                                              CanDisable: false)
                    Divider()
                        .background(Color.black)
                    BultInImageTableEntryView(ImageName: "Sample2",
                                              ImageDescription: "Sample 2",
                                              OverallWidth: Reader.size.width,
                                              ImageIsEnabled: Sample2Enabled)
                    Divider()
                        .background(Color.black)
                    BultInImageTableEntryView(ImageName: "Sample3",
                                              ImageDescription: "Sample 3",
                                              OverallWidth: Reader.size.width,
                                              ImageIsEnabled: Sample3Enabled)
                    Divider()
                        .background(Color.black)
                    BultInImageTableEntryView(ImageName: "Sample4",
                                              ImageDescription: "Sample 4",
                                              OverallWidth: Reader.size.width,
                                              ImageIsEnabled: Sample4Enabled)
                    Divider()
                        .background(Color.black)
                }
                Group
                {
                    BultInImageTableEntryView(ImageName: "Sample5",
                                              ImageDescription: "Sample 5",
                                              OverallWidth: Reader.size.width,
                                              ImageIsEnabled: Sample5Enabled)
                    Divider()
                        .background(Color.black)
                    BultInImageTableEntryView(ImageName: "Sample6",
                                              ImageDescription: "Sample 6",
                                              OverallWidth: Reader.size.width,
                                              ImageIsEnabled: Sample6Enabled)
                    Divider()
                        .background(Color.black)
                    BultInImageTableEntryView(ImageName: "Sample7",
                                              ImageDescription: "Sample 7",
                                              OverallWidth: Reader.size.width,
                                              ImageIsEnabled: Sample7Enabled)
                    Divider()
                        .background(Color.black)
                    BultInImageTableEntryView(ImageName: "Sample8",
                                              ImageDescription: "Sample 8",
                                              OverallWidth: Reader.size.width,
                                              ImageIsEnabled: Sample8Enabled)
                    Divider()
                        .background(Color.black)
                }
            }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle(Text("Bulit-in Sample Images"))
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
