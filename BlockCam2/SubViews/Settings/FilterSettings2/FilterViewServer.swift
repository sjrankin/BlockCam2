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
                
            case BuiltInFilters.Kaleidoscope.rawValue:
                SettingsContainer
                {
                    KaleidoscopeFilter_View()
                }
                
            case BuiltInFilters.TriangleKaleidoscope.rawValue:
                SettingsContainer
                {
                    TriangleKaleidoscopeFilter_View()
                }
                
            case BuiltInFilters.Mirroring2.rawValue:
                SettingsContainer
                {
                    MirrorFilter_View()
                }
                
            case BuiltInFilters.ColorMap.rawValue:
                SettingsContainer
                {
                    ColorMapFilter_View()
                }
                
            case BuiltInFilters.ColorMonochrome.rawValue:
                SettingsContainer
                {
                    ColorMonochromeFilter_View()
                }
                
            case BuiltInFilters.Bloom.rawValue,
                 BuiltInFilters.CircleAndLines.rawValue,
                 BuiltInFilters.ColorInvert.rawValue,
                 BuiltInFilters.Chrome.rawValue,
                 BuiltInFilters.EdgeWork.rawValue,
                 BuiltInFilters.Fade.rawValue,
                 BuiltInFilters.GaborGradients.rawValue,
                 BuiltInFilters.Gloom.rawValue,
                 BuiltInFilters.Instant.rawValue,
                 BuiltInFilters.LinearTosRGB.rawValue,
                 BuiltInFilters.MaximumComponent.rawValue,
                 BuiltInFilters.MinimumComponent.rawValue,
                 BuiltInFilters.Mono.rawValue,
                 BuiltInFilters.Noir.rawValue,
                 BuiltInFilters.Otsu.rawValue,
                 BuiltInFilters.Passthrough.rawValue,
                 BuiltInFilters.Process.rawValue,
                 BuiltInFilters.Sobel.rawValue,
                 BuiltInFilters.SobelBlend.rawValue,
                 BuiltInFilters.ThermalEffect.rawValue,
                 BuiltInFilters.Tonal.rawValue,
                 BuiltInFilters.Transfer.rawValue,
                 BuiltInFilters.XRay.rawValue:
                NoFilter_View(FilterName: Settings.GetString(.CurrentFilter, "Unknown"))
            
            default:
                SettingsContainer
                {
                    NoFilter_View(FilterName: Settings.GetString(.CurrentFilter, "Unknown"))
                }
        }
    }
}
