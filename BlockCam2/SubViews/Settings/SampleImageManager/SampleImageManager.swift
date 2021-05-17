//
//  SampleImageManager.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/17/21.
//

import SwiftUI

struct RunSampleImageSettingView: View
{
    @State var ViewToRun: String
    
    var body: some View
    {
        switch ViewToRun
        {
            case "Built-in":
                BuiltInSampleImageManager()
                
            case "Your images":
                UnexpectedView()
                
            case "Other options":
                OtherSampleImageOptions()
                
            default:
                UnexpectedView()
        }
    }
}

struct SampleImageManager: View
{
    var OptionList: [OptionItem] = SampleImageOptions
    @Environment(\.presentationMode) var presentionMode: Binding<PresentationMode>
    
    var body: some View
    {
            List(OptionList)
            {
                SomeOption in
                NavigationLink(destination: RunSampleImageSettingView(ViewToRun: SomeOption.Title))
                {
                    SettingsItemView(SettingData: SomeOption)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle(Text("Sample Image Settings"))
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

struct SampleImageManager_Previews: PreviewProvider
{
    static var previews: some View
    {
        SampleImageManager()
    }
}
