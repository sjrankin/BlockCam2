//
//  FilterViewServer.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/30/21.
//

import Foundation
import SwiftUI

struct SettingsContainer<Content: View>: View
{
    let ViewMaker: () -> Content
    
    var body: some View
    {
        NavigationView
        {
        ViewMaker()
            .navigationBarTitle(Text(Settings.GetString(.CurrentFilter, "")))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct FilterViewServer: View
{
    @Binding var IsVisible: Bool
    
    var body: some View
    {
        switch Settings.GetString(.CurrentFilter)
        {
            case BuiltInFilters.HueAdjust.rawValue:
                SettingsContainer
                {
                    HueAdjustFilter_View()
                }
                .opacity(IsVisible ? 1.0 : 0.0)
                
            case BuiltInFilters.Kaleidoscope.rawValue:
                SettingsContainer
                {
                    KaleidoscopeFilter_View()
                }
                .opacity(IsVisible ? 1.0 : 0.0)
                
            case BuiltInFilters.TriangleKaleidoscope.rawValue:
                SettingsContainer
                {
                    TriangleKaleidoscopeFilter_View()
                }
                .opacity(IsVisible ? 1.0 : 0.0)
            
            default:
                SettingsContainer
                {
                    NoFilter_View(FilterName: "Unknown")
                }
                .opacity(IsVisible ? 1.0 : 0.0)
        }
    }
}
