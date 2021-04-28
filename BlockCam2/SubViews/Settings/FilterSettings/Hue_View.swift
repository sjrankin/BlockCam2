//
//  Hue_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/28/21.
//

import Foundation
import SwiftUI

struct Hue_View: View
{
    @ObservedObject var Storage = SettingsUI()
    @State var CurrentAngle: String = "0.0"
    
    var body: some View
    {
        VStack()
        {
            HStack
            {
                Text("Hue angle")
                TextField("0.0", text: $CurrentAngle)
            }
        }
    }
}
