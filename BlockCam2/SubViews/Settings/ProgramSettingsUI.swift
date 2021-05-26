//
//  ProgramSettingsUI.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/27/21.
//

import SwiftUI

struct RunSettingView: View
{
    @EnvironmentObject var Changed: ChangedSettings
    @State var ViewToRun: String
    
    var body: some View
    {
        switch ViewToRun
        {
            case "Settings":
                SettingsView() 
                
            case "About":
                AboutView()
                
            case "Sample Images":
                SampleImageManager()
                
            case "Camera":
                CameraSettings()
                
            case "Filter List":
                AllFilterView()
                    .environmentObject(Changed)
                
            default:
                UnexpectedView()
        }
    }
}

struct ProgramSettingsUI: View
{
    @EnvironmentObject var Changed: ChangedSettings
    var OptionList: [OptionItem] = []
    @Environment(\.presentationMode) var presentionMode: Binding<PresentationMode>
    
    var body: some View
    {
        NavigationView
        {
            List(OptionList)
            {
                SomeOption in
                NavigationLink(destination: RunSettingView(ViewToRun: SomeOption.Title)
                                .environmentObject(Changed))
                {
                    SettingsItemView(SettingData: SomeOption)
                }
            }
            .navigationBarTitle(Text("BlockCam Settings"))
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

struct ProgramSettingsUI_Previews: PreviewProvider
{
    static var previews: some View
    {
        ProgramSettingsUI(OptionList: SettingsData)
            .environmentObject(ChangedSettings())
    }
}
