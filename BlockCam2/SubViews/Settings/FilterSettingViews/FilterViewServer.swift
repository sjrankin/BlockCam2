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
    @State var NoSettings: Bool = false
    let ViewMaker: () -> Content
    @Environment(\.presentationMode) var Presentation
    @State var ShowResetAlert: Bool = false
    @EnvironmentObject var Changed: ChangedSettings
    
    var body: some View
    {
        NavigationView
        {
            ViewMaker()
                .navigationBarTitle(Text(Settings.GetString(.CurrentFilter, "")))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar
                {
                    // Filter reset button
                    ToolbarItem(placement: .navigationBarLeading)
                    {
                        Button(action:
                                {
                                    ShowResetAlert.toggle()
                                })
                        {
                            Image(systemName: "arrow.counterclockwise.circle.fill")
                        }
                        .disabled($NoSettings.wrappedValue)
                    }
                    // Close filter page button
                    ToolbarItem(placement: .navigationBarTrailing)
                    {
                        Button(action:
                                {
                                    self.Presentation.wrappedValue.dismiss()
                                }
                        )
                        {
                            Image(systemName: "x.circle.fill")
                        }
                    }
                }
        }
        .actionSheet(isPresented: $ShowResetAlert)
        {
            ActionSheet(
                title: Text("Reset Filter?"),
                message: Text("Do you really want to reset the \"\(Settings.GetString(.CurrentFilter, "unknown"))\" filter to its original settings?"),
                buttons:
                    [
                        .cancel(),
                        .destructive(Text("Reset"))
                        {
                            Settings.ResetCurrentFilter()
                            Changed.ChangedFilter = Settings.GetString(.CurrentFilter, "")
                        }
                    ]
            )
        }
    }
}

struct FilterViewServer: View
{
    @Binding var UICommand: String
    @Binding var IsVisible: Bool
    @EnvironmentObject var Changed: ChangedSettings
    
    var body: some View
    {
        switch Settings.GetString(.CurrentFilter)
        {
            case BuiltInFilters.CircularWrap.rawValue:
                SettingsContainer
                {
                    CircularWrapFilter_View(ButtonCommand: $UICommand)
                        .environmentObject(Changed)
                }.environmentObject(Changed)
            
            case BuiltInFilters.LineScreen.rawValue:
                SettingsContainer
                {
                    LineScreenFilter_View(ButtonCommand: $UICommand)
                        .environmentObject(Changed)
                }.environmentObject(Changed)
            
            case BuiltInFilters.TwirlBump.rawValue:
                SettingsContainer
                {
                    TwirlBumpFilter_View(ButtonCommand: $UICommand)
                        .environmentObject(Changed)
                }.environmentObject(Changed)
            
            case BuiltInFilters.MetalPixellate.rawValue:
                SettingsContainer
                {
                    MetalPixellateFilter_View(ButtonCommand: $UICommand)
                        .environmentObject(Changed)
                }.environmentObject(Changed)
            
            case BuiltInFilters.Kuwahara.rawValue:
                SettingsContainer
                {
                    KuwaharaFilter_View(ButtonCommand: $UICommand)
                        .environmentObject(Changed)
                }.environmentObject(Changed)
            
            case BuiltInFilters.SolarizeRGB.rawValue:
                SettingsContainer
                {
                    SolarizationRGBFilter_View(ButtonCommand: $UICommand)
                        .environmentObject(Changed)
                }.environmentObject(Changed)
            
            case BuiltInFilters.SolarizeHSB.rawValue:
                SettingsContainer
                {
                    SolarizationHSBFilter_View(ButtonCommand: $UICommand)
                        .environmentObject(Changed)
                }.environmentObject(Changed)
                
            /*
            case BuiltInFilters.Solarize.rawValue:
                SettingsContainer
                {
                    SolarizationFilter_View(ButtonCommand: $UICommand)
                        .environmentObject(Changed)
                }.environmentObject(Changed)
            */
            case BuiltInFilters.ConditionalSilhouette.rawValue:
                SettingsContainer
                {
                    ConditionalSilhouetteFilter_View(ButtonCommand: $UICommand)
                        .environmentObject(Changed)
                }.environmentObject(Changed)
            
            case BuiltInFilters.ChannelMixer.rawValue:
                SettingsContainer
                {
                    ChannelMixerFilter_View(ButtonCommand: $UICommand)
                        .environmentObject(Changed)
                }.environmentObject(Changed)
            
            case BuiltInFilters.ChannelMangler.rawValue:
                SettingsContainer
                {
                    ChannelManglerFilter_View(ButtonCommand: $UICommand) 
                        .environmentObject(Changed)
                }.environmentObject(Changed)
            
            case BuiltInFilters.MetalGrayscale.rawValue:
                SettingsContainer
                {
                    GrayscaleMetalFilter_View(ButtonCommand: $UICommand)
                        .environmentObject(Changed)
                }.environmentObject(Changed)
            
            case BuiltInFilters.Convolution.rawValue:
                SettingsContainer
                {
                    ConvolutionFilter_View(ButtonCommand: $UICommand)
                        .environmentObject(Changed)
                }.environmentObject(Changed)
            
            case BuiltInFilters.Threshold.rawValue:
                SettingsContainer
                {
                    ThresholdFilter2_View(ButtonCommand: $UICommand)
                        .environmentObject(Changed)
                }.environmentObject(Changed)
                
            case BuiltInFilters.EdgeWork.rawValue:
                SettingsContainer
                {
                    EdgeWorkFilter_View(ButtonCommand: $UICommand)
                        .environmentObject(Changed)
                }.environmentObject(Changed)
            
            case BuiltInFilters.Sepia.rawValue:
                SettingsContainer
                {
                    SepiaFilter_View(ButtonCommand: $UICommand)
                        .environmentObject(Changed)
                }.environmentObject(Changed)
                
            case BuiltInFilters.TwirlDistortion.rawValue:
                SettingsContainer
                {
                    TwirlDistortionFilter_View(ButtonCommand: $UICommand)
                        .environmentObject(Changed)
                }.environmentObject(Changed)
            
            case BuiltInFilters.BumpDistortion.rawValue:
                SettingsContainer
                {
                    BumpDistorionFilter_View(ButtonCommand: $UICommand)
                        .environmentObject(Changed)
                }.environmentObject(Changed)
                
            case BuiltInFilters.UnsharpMask.rawValue:
                SettingsContainer
                {
                    UnsharpMaskFilter_View(ButtonCommand: $UICommand)
                        .environmentObject(Changed)
                }.environmentObject(Changed)
                
            case BuiltInFilters.ExposureAdjust.rawValue:
                SettingsContainer
                {
                    ExposureFilter_View(ButtonCommand: $UICommand)
                        .environmentObject(Changed)
                }.environmentObject(Changed)
                
            case BuiltInFilters.Droste.rawValue:
                SettingsContainer
                {
                    DrosteFilter_View(ButtonCommand: $UICommand)
                        .environmentObject(Changed)
                }.environmentObject(Changed)
                
            case BuiltInFilters.Edges.rawValue:
                SettingsContainer
                {
                    EdgesFilter_View(ButtonCommand: $UICommand)
                        .environmentObject(Changed)
                }.environmentObject(Changed)
                
            case BuiltInFilters.DotScreen.rawValue:
                SettingsContainer
                {
                    DotScreenFilter_View(ButtonCommand: $UICommand)
                        .environmentObject(Changed)
                }.environmentObject(Changed)
                
            case BuiltInFilters.Dither.rawValue:
                SettingsContainer
                {
                    DitherFilter_View(ButtonCommand: $UICommand)
                        .environmentObject(Changed)
                }.environmentObject(Changed)
                
            case BuiltInFilters.CMYKHalftone.rawValue:
                SettingsContainer
                {
                    CMYKHalftoneFilter_View(ButtonCommand: $UICommand)
                        .environmentObject(Changed)
                }.environmentObject(Changed)
                
            case BuiltInFilters.HueAdjust.rawValue:
                SettingsContainer
                {
                    HueAdjustFilter_View(ButtonCommand: $UICommand)
                        .environmentObject(Changed)
                }.environmentObject(Changed)
                
            case BuiltInFilters.Kaleidoscope.rawValue:
                SettingsContainer
                {
                    KaleidoscopeFilter_View(ButtonCommand: $UICommand)
                        .environmentObject(Changed)
                }.environmentObject(Changed)
                
            case BuiltInFilters.TriangleKaleidoscope.rawValue:
                SettingsContainer
                {
                    TriangleKaleidoscopeFilter_View(ButtonCommand: $UICommand)
                        .environmentObject(Changed)
                }.environmentObject(Changed)
                
            case BuiltInFilters.Mirroring2.rawValue:
                SettingsContainer
                {
                    MirrorFilter_View(ButtonCommand: $UICommand)
                        .environmentObject(Changed)
                }.environmentObject(Changed)
                
            case BuiltInFilters.ColorMap.rawValue:
                SettingsContainer
                {
                    ColorMapFilter_View(ButtonCommand: $UICommand)
                        .environmentObject(Changed)
                }.environmentObject(Changed)
                
            case BuiltInFilters.ColorMonochrome.rawValue:
                SettingsContainer
                {
                    ColorMonochromeFilter_View(ButtonCommand: $UICommand)
                        .environmentObject(Changed)
                }.environmentObject(Changed)
                
            case BuiltInFilters.ColorControls.rawValue:
                SettingsContainer
                {
                    ColorControlsFilter_View(ButtonCommand: $UICommand)
                        .environmentObject(Changed)
                }.environmentObject(Changed)
                
            case BuiltInFilters.HSB.rawValue:
                SettingsContainer
                {
                    HSBFilter_View(ButtonCommand: $UICommand)
                        .environmentObject(Changed)
                }.environmentObject(Changed)
                
            case BuiltInFilters.Vibrance.rawValue:
                SettingsContainer
                {
                    VibranceFilter_View(ButtonCommand: $UICommand)
                        .environmentObject(Changed)
                }.environmentObject(Changed)
                
            case BuiltInFilters.CircleSplashDistortion.rawValue:
                SettingsContainer
                {
                    CircleSplashDistortionFilter_View(ButtonCommand: $UICommand)
                        .environmentObject(Changed)
                }.environmentObject(Changed)
                
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
                SettingsContainer(NoSettings: true)
                {
                    NoFilter_View(ButtonCommand: $UICommand,
                                  FilterName: Settings.GetString(.CurrentFilter, "Unknown"))
                        .environmentObject(Changed)
                }.environmentObject(Changed)
                
            default:
                SettingsContainer(NoSettings: true)
                {
                    NoFilter_View(ButtonCommand: $UICommand,
                                  FilterName: Settings.GetString(.CurrentFilter, "Unknown"))
                        .environmentObject(Changed)
                }.environmentObject(Changed)
        }
    }
}
