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
    @State var FilterName: String
    
    var body: some View
    {
        ScrollView
        {
            Text(FilterName == "Unknown" ? "Unknown Filter" : "No settings for \(FilterName)")
                .padding()
        }
    }
}
