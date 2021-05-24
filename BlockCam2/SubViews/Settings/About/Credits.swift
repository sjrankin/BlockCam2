//
//  Credits.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/23/21.
//

import SwiftUI

struct CreditsItemView: View
{
    @State var ViewToRun: String
    
    var body: some View
    {
        switch ViewToRun
        {
            case "Visual":
                VisualCreditsView()
                
            case "Technical":
                CodeCreditsView()
                
            default:
                UnexpectedView()
        }
    }
}

struct CreditsView: View
{
    @Environment(\.presentationMode) var presentionMode: Binding<PresentationMode>
    @State var ShowCredits: Bool = false
    
    var body: some View
    {
        GeometryReader
        {
            Geometry in
            VStack(alignment: .leading)
            {
                List(CreditImageOptions)
                {
                    SomeOption in
                    NavigationLink(destination: CreditsItemView(ViewToRun: SomeOption.Title))
                    {
                        SettingsItemView(SettingData: SomeOption)
                    }
                }
            }
            .padding()
        }
        .navigationBarTitle(Text("Credits"))
        .navigationBarTitleDisplayMode(.inline)
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

struct CreditsView_Previews: PreviewProvider
{
    static var previews: some View
    {
        AboutView()
    }
}
