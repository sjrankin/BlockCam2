//
//  AllFiltersMetaView.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/25/21.
//

import SwiftUI

struct AllFiltersMetaView<Content: View>: View
{
    let ViewMaker: () -> Content
    
    var body: some View
    {
        Group
        {
            ViewMaker()
        }
    }
}

struct AllFiltersDependentView: View
{
    @EnvironmentObject var Changed: ChangedSettings
    @Binding var DisplayType: Int
    @State var Width: CGFloat
    
    var body: some View
    {
        switch DisplayType
        {
            case 0:
                AllFiltersMetaView
                {
                    AllFiltersByNameView(Width: Width)
                        .environmentObject(Changed)
                }
                
            case 1:
                AllFiltersMetaView
                {
                    AllFiltersByGroupView(Width: Width)
                        .environmentObject(Changed)
                }
                
            default:
                AllFiltersMetaView
                {
                    AllFiltersByNameView(Width: Width)
                        .environmentObject(Changed)
                }
        }
    }
}
