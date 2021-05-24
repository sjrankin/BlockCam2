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
        OptionItem(Title: "About",
                   Annotation: "About BlockCam",
                   Picture: "info.circle"),
        OptionItem(Title: "Settings",
                   Annotation: "General program settings",
                   Picture: "gearshape"),
        OptionItem(Title: "Camera",
                   Annotation: "Camera and image settings",
                   Picture: "camera"),
        OptionItem(Title: "Sample Images",
                   Annotation: "Manage sample images.",
                   Picture: "photo.on.rectangle")
    ]

let SampleImageOptions =
    [
        OptionItem(Title: "Built-in",
                   Annotation: "Manage built-in sample images",
                   Picture: "photo"),
        OptionItem(Title: "Your images",
                   Annotation: "Manage you own sample images",
                   Picture: "person.crop.circle"),
        OptionItem(Title: "Other options",
                   Annotation: "Other options for sample images",
                   Picture: "circle.dashed.inset.fill")
    ]

let CreditImageOptions =
    [
        OptionItem(Title: "Visual",
                   Annotation: "Acknowlegements related to visuals",
                   Picture: "eye"),
        OptionItem(Title: "Technical",
                   Annotation: "Acknowlegements for technically-related issues",
                   Picture: "chevron.left.slash.chevron.right"),
    ]
