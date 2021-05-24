//
//  CodeCreditsView.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/23/21.
//

import Foundation
import SwiftUI

struct CodeCreditsView: View
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
                    Text("Stack Overflow")
                        .font(.headline)
                    Text("Multiple Stack Overflow pages were consulted and links provided in the source code.")
                        .font(.subheadline)
                }
                .padding()
                Divider()
                    .background(Color.black)
            }
            .padding()
            .navigationBarTitle(Text("Technical Credits"))
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

struct CodeCreditsView_Preview: PreviewProvider
{
    static var previews: some View
    {
        CodeCreditsView()
    }
}
