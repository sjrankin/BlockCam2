//
//  NoFilter_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/30/21.
//

import Foundation
import SwiftUI

struct NoFilter_View: View
{
    @Binding var ButtonCommand: String
    @State var FilterName: String
    
    var body: some View
    {
        ScrollView
        {
            VStack
            {
                Text(FilterName == "Unknown" ? "Unknown Filter" : "No settings for \(FilterName)")
                    .padding()
                
                Spacer()
                
                Divider()
                    .background(Color.black)
                
                SampleImage(UICommand: $ButtonCommand,
                            Filter: Filters.GetFilter(),
                            Updated: true)
                    .frame(width: 300, height: 300, alignment: .center)
            }
        }
    }
}

struct NoFilter_Preview: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        NoFilter_View(ButtonCommand: $NotUsed, FilterName: "Placeholder Filter")
    }
}
