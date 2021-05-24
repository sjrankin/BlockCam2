//
//  AboutView.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/27/21.
//

import SwiftUI

struct AboutView: View
{
    @Environment(\.presentationMode) var presentionMode: Binding<PresentationMode>
    
    var body: some View
    {
        GeometryReader
        {
            Geometry in
            VStack(alignment: .leading)
            {
                Text("BlockCam")
                    .font(.custom("Avenir-Heavy", size: 30))
                    .padding(.bottom)
                Text("\(Versioning.MakeVersionString())")
                    .font(.custom("Avenir", size: 18))
                Text("\(Versioning.MakeBuildString())")
                    .font(.custom("Avenir", size: 18))
                Text("\(Versioning.CopyrightText())")
                    .font(.custom("Avenir", size: 18))

                NavigationLink(destination: CreditsView())
                {
                    Text("Credits and Acknowledgments")
                }
                .padding(.top, 100)
            }
            .padding()
            .navigationBarTitle(Text("About BlockCam"))
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
}

struct AboutView_Previews: PreviewProvider
{
    static var previews: some View
    {
        AboutView()
    }
}
