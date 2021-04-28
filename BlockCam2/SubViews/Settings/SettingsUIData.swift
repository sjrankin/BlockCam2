//
//  SettingsUIData.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/27/21.
//

import SwiftUI

struct OptionItem: Identifiable
{
    var id = UUID()
    var Title: String
    var Annotation: String
    var Picture: String
}

let SettingsData =
    [
        OptionItem(Title: "Settings",
                   Annotation: "General program settings",
                   Picture: "gearshape"),
        OptionItem(Title: "About",
                   Annotation: "About BlockCam",
                   Picture: "info.circle")
    ]
