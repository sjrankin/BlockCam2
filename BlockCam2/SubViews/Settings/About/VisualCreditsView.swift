//
//  VisualCreditsView.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/23/21.
//

import SwiftUI

struct VisualCreditsView: View
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
                VStack(alignment: .leading)
                {
                    Text("Built-in Samples")
                        .font(.headline)
                    Text("Some built-in sample images created by the author of this program and are released to public domain. Others are from Unsplash - see attributions on individual images.")
                        .font(.subheadline)
                }
                .padding()
                Divider()
                    .background(Color.black)
                
                VStack(alignment: .leading)
                {
                    Text("SF Symbols")
                        .font(.headline)
                    Text("Many icons are from Apple's SF Symbol set. Used as per Apple SDK license agreements.")
                        .font(.subheadline)
                }
                .padding()
                Divider()
                    .background(Color.black)

            }
            .padding()
            .navigationBarTitle(Text("Visual Credits"))
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

struct VisualCreditsView_Preview: PreviewProvider
{
    static var previews: some View
    {
        VisualCreditsView()
    }
}
