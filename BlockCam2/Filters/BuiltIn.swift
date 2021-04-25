//
//  BuiltIn.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/21/21.
//

import Foundation
import UIKit
import SceneKit
import AVFoundation
import CoreImage
import CoreServices
import AVKit
import Photos
import MobileCoreServices
import CoreMotion
import CoreMedia
import CoreVideo
import CoreImage.CIFilterBuiltins

extension Filters
{
    public static func InitializeBuiltInFilters()
    {
        BuiltInFilterMap[.Bloom] = BlockCam2.Bloom()
        BuiltInFilterMap[.Chrome] = BlockCam2.Chrome()
        BuiltInFilterMap[.CircularScreen] = BlockCam2.CircularScreen()
        BuiltInFilterMap[.CMYKHalftone] = BlockCam2.CMYKHalftone()
        BuiltInFilterMap[.ColorMonochrome] = BlockCam2.ColorMonochrome()
        //BuiltInFilterMap[.Comic] = BlockCam2.Comic()
        BuiltInFilterMap[.Crystallize] = BlockCam2.Crystallize()
        BuiltInFilterMap[.DotScreen] = BlockCam2.DotScreen()
        BuiltInFilterMap[.Edges] = BlockCam2.Edges()
        BuiltInFilterMap[.EdgeWork] = BlockCam2.EdgeWork()
        BuiltInFilterMap[.ExposureAdjust] = BlockCam2.ExposureAdjust()
        BuiltInFilterMap[.Fade] = BlockCam2.Fade()
        BuiltInFilterMap[.FalseColor] = BlockCam2.FalseColor()
        BuiltInFilterMap[.Gloom] = BlockCam2.Gloom()
        BuiltInFilterMap[.HatchedScreen] = BlockCam2.HatchedScreen()
        BuiltInFilterMap[.HexagonalPixellate] = BlockCam2.HexagonalPixellate()
        BuiltInFilterMap[.HistogramDisplay] = BlockCam2.HistogramDisplay()
        BuiltInFilterMap[.HueAdjust] = BlockCam2.HueAdjust()
        BuiltInFilterMap[.Instant] = BlockCam2.Instant()
        BuiltInFilterMap[.Kaleidoscope] = BlockCam2.Kaleidoscope()
        BuiltInFilterMap[.LinearTosRGB] = BlockCam2.LinearTosRGB()
        BuiltInFilterMap[.LineOverlay] = BlockCam2.LineOverlay()
        BuiltInFilterMap[.LineScreen] = BlockCam2.LineScreen()
        BuiltInFilterMap[.MaximumComponent] = BlockCam2.MaximumComponent()
        BuiltInFilterMap[.MinimumComponent] = BlockCam2.MinimumComponent()
        BuiltInFilterMap[.Mono] = BlockCam2.Mono() 
        BuiltInFilterMap[.Noir] = BlockCam2.Noir()
        BuiltInFilterMap[.Passthrough] = BlockCam2.Passthrough()
        BuiltInFilterMap[.Pixellate] = BlockCam2.Pixellate()
        BuiltInFilterMap[.Pointillize] = BlockCam2.Pointillize()
        BuiltInFilterMap[.Posterize] = BlockCam2.Posterize()
        BuiltInFilterMap[.Process] = BlockCam2.Process()
        BuiltInFilterMap[.Sepia] = BlockCam2.Sepia()
        BuiltInFilterMap[.SharpenLuminance] = BlockCam2.SharpenLuminance()
        BuiltInFilterMap[.Tonal] = BlockCam2.Tonal()
        BuiltInFilterMap[.Transfer] = BlockCam2.Transfer()
        BuiltInFilterMap[.TriangleKaleidoscope] = BlockCam2.TriangleKaleidoscope()
        BuiltInFilterMap[.UnsharpMask] = BlockCam2.UnsharpMask()
        BuiltInFilterMap[.Vibrance] = BlockCam2.Vibrance()
        BuiltInFilterMap[.XRay] = BlockCam2.XRay()
    }
    
    public static var BuiltInFilterMap = [BuiltInFilters: BuiltInFilterProtocol]()
    
    private static func MakeBlurFilters() -> [BuiltInFilters: BuiltInFilterProtocol]?
    {
        var FilterMap = [BuiltInFilters: BuiltInFilterProtocol]()
        FilterMap[.GaussianBlur] = BlockCam2.GaussianBlur()
        FilterMap[.MedianFilter] = BlockCam2.MedianFilter()
        FilterMap[.MotionBlur] = BlockCam2.MotionBlur()
        FilterMap[.ZoomBlur] = BlockCam2.ZoomBlur()
        return FilterMap
    }
    
    private static func Make3DFilters() -> [BuiltInFilters: BuiltInFilterProtocol]?
    {
        var FilterMap = [BuiltInFilters: BuiltInFilterProtocol]()
        FilterMap[.Blocks] = BlockCam2.Passthrough()
        FilterMap[.Spheres] = BlockCam2.Passthrough()
        return FilterMap
    }
    
    private static func MakeCombinedFilters() -> [BuiltInFilters: BuiltInFilterProtocol]?
    {
        return nil
    }
    
    private static func MakeColorFilters() -> [BuiltInFilters: BuiltInFilterProtocol]?
    {
        var FilterMap = [BuiltInFilters: BuiltInFilterProtocol]()
        FilterMap[.FalseColor] = BlockCam2.FalseColor()
        FilterMap[.Sepia] = BlockCam2.Sepia()
        FilterMap[.ColorMonochrome] = BlockCam2.ColorMonochrome()
        FilterMap[.LinearTosRGB] = BlockCam2.LinearTosRGB()
        FilterMap[.ColorInvert] = BlockCam2.ColorInvert()
        FilterMap[.ColorMap] = BlockCam2.ColorMap()
        return FilterMap
    }
    
    private static func MakeAdjustmentFilters() -> [BuiltInFilters: BuiltInFilterProtocol]?
    {
        var FilterMap = [BuiltInFilters: BuiltInFilterProtocol]()
        FilterMap[.HueAdjust] = BlockCam2.HueAdjust()
        FilterMap[.ExposureAdjust] = BlockCam2.ExposureAdjust()
        return FilterMap
    }
    
    private static func MakeSharpenFilters() -> [BuiltInFilters: BuiltInFilterProtocol]?
    {
        var FilterMap = [BuiltInFilters: BuiltInFilterProtocol]()
        FilterMap[.UnsharpMask] = BlockCam2.UnsharpMask()
        FilterMap[.SharpenLuminance] = BlockCam2.SharpenLuminance()
        return FilterMap
    }
    
    private static func MakeInfoFilters() -> [BuiltInFilters: BuiltInFilterProtocol]?
    {
        var FilterMap = [BuiltInFilters: BuiltInFilterProtocol]()
        FilterMap[.HistogramDisplay] = BlockCam2.HistogramDisplay()
        return FilterMap
    }
    
    private static func MakeGrayscaleFilters() -> [BuiltInFilters: BuiltInFilterProtocol]?
    {
        var FilterMap = [BuiltInFilters: BuiltInFilterProtocol]()
        FilterMap[.Noir] = BlockCam2.Noir()
        FilterMap[.Mono] = BlockCam2.Mono()
        FilterMap[.MaximumComponent] = BlockCam2.MaximumComponent()
        FilterMap[.MinimumComponent] = BlockCam2.MinimumComponent()
        FilterMap[.EdgeWork] = BlockCam2.EdgeWork()
        FilterMap[.GrayscaleInvert] = BlockCam2.GrayscaleInvert()
        return FilterMap
    }
    
    private static func MakeDistortionFilters() -> [BuiltInFilters: BuiltInFilterProtocol]?
    {
        var FilterMap = [BuiltInFilters: BuiltInFilterProtocol]()
        FilterMap[.Posterize] = BlockCam2.Posterize()
        FilterMap[.Pixellate] = BlockCam2.Pixellate()
        FilterMap[.TriangleKaleidoscope] = BlockCam2.TriangleKaleidoscope()
        FilterMap[.Kaleidoscope] = BlockCam2.Kaleidoscope()
        FilterMap[.Crystallize] = BlockCam2.Crystallize()
        FilterMap[.HexagonalPixellate] = BlockCam2.HexagonalPixellate()
        FilterMap[.Pointillize] = BlockCam2.Pointillize()
        FilterMap[.Droste] = BlockCam2.Droste()
        FilterMap[.CircleSplashDistortion] = BlockCam2.CircleSplashDistortion()
        FilterMap[.BumpDistortion] = BlockCam2.BumpDistortion()
        FilterMap[.HoleDistortion] = BlockCam2.HoleDistortion()
        FilterMap[.LightTunnel] = BlockCam2.LightTunnel()
        FilterMap[.TwirlDistortion] = BlockCam2.TwirlDistortion()
        return FilterMap
    }
    
    private static func MakeEffectFilters() -> [BuiltInFilters: BuiltInFilterProtocol]?
    {
        var FilterMap = [BuiltInFilters: BuiltInFilterProtocol]()
        FilterMap[.Chrome] = BlockCam2.Chrome()
        FilterMap[.Instant] = BlockCam2.Instant()
        FilterMap[.Fade] = BlockCam2.Fade()
        FilterMap[.Process] = BlockCam2.Process()
        FilterMap[.Tonal] = BlockCam2.Tonal()
        FilterMap[.Transfer] = BlockCam2.Transfer()
        FilterMap[.Vibrance] = BlockCam2.Vibrance()
        FilterMap[.XRay] = BlockCam2.XRay()
        FilterMap[.Bloom] = BlockCam2.Bloom()
        FilterMap[.Gloom] = BlockCam2.Gloom()
        FilterMap[.Edges] = BlockCam2.Edges()
        FilterMap[.LineOverlay] = BlockCam2.LineOverlay()
        FilterMap[.ThermalEffect] = BlockCam2.Thermal()
        return FilterMap
    }
    
    private static func MakeHalftoneFilters() -> [BuiltInFilters: BuiltInFilterProtocol]?
    {
        var FilterMap = [BuiltInFilters: BuiltInFilterProtocol]()
        FilterMap[.DotScreen] = BlockCam2.DotScreen()
        FilterMap[.LineScreen] = BlockCam2.LineScreen()
        FilterMap[.CircularScreen] = BlockCam2.CircularScreen()
        FilterMap[.HatchedScreen] = BlockCam2.HatchedScreen()
        FilterMap[.CMYKHalftone] = BlockCam2.CMYKHalftone()
        FilterMap[.CircleAndLines] = BlockCam2.CircleAndLines()
        FilterMap[.LineScreenBlend] = BlockCam2.LineScreenBlend()
        FilterMap[.CircleScreenBlend] = BlockCam2.CircleScreenBlend()
        return FilterMap
    }
    
    private static func MakeResetFilters() -> [BuiltInFilters: BuiltInFilterProtocol]?
    {
        var FilterMap = [BuiltInFilters: BuiltInFilterProtocol]()
        FilterMap[.Passthrough] = BlockCam2.Passthrough()
        return FilterMap
    }
    
    public static func InitializeFilterTree()
    {
        if TreeInitialized
        {
            return
        }
        FilterTree = [(FilterGroups, [BuiltInFilters: BuiltInFilterProtocol])]()
        for Group in FilterGroups.allCases
        {
            var FilterData: [BuiltInFilters: BuiltInFilterProtocol]? = nil
            switch Group
            {
                case .Reset:
                    FilterData = MakeResetFilters()
                
                case .Adjust:
                    FilterData = MakeAdjustmentFilters()
                    
                case .Blur:
                    FilterData = MakeBlurFilters()
                    
                case .Color:
                    FilterData = MakeColorFilters()
                    
                case .Combined:
                    FilterData = MakeCombinedFilters()
                    
                case .Distortion:
                    FilterData = MakeDistortionFilters()
                    
                case .Effect:
                    FilterData = MakeEffectFilters()
                    
                case .Grayscale:
                    FilterData = MakeGrayscaleFilters()
                    
                case .Halftone:
                    FilterData = MakeHalftoneFilters()
                    
                case .Information:
                    FilterData = MakeInfoFilters()
                    
                case .Sharpen:
                    FilterData = MakeSharpenFilters()
                    
                case .ThreeD:
                    FilterData = Make3DFilters()
            }
            if let Final = FilterData
            {
                FilterTree.append((Group, Final))
            }
        }
        _TreeInitialized = true
    }
    
    private static var _TreeInitialized: Bool = false
    public static var TreeInitialized: Bool
    {
        get
        {
            return _TreeInitialized
        }
    }
    
    /// Given a filter type, return its instantiation.
    /// - Parameter Filter: The filter type to return.
    /// - Returns: Instantiation of the filter specfied in `Filter`. Nil on error.
    public static func FilterFromTree(_ Filter: BuiltInFilters) -> BuiltInFilterProtocol?
    {
        for (_, FilterList) in FilterTree
        {
            if FilterList.keys.contains(Filter)
            {
                return FilterList[Filter]!
            }
        }
        return nil
    }
    
    /// Simple tree of filters.
    public static var FilterTree = [(FilterGroups, [BuiltInFilters: BuiltInFilterProtocol])]()
    
    /// Returns a structure of filter groups and filter names in each group.
    /// - Returns: An array of tuples with the first item the group name and the second item an array of
    ///            filter names.
    public static func GetFilterTreeStructure() -> [(String, [String])]
    {
        var GroupNames = [(String, [String])]()
        for (Group, Filters) in FilterTree
        {
            let GroupName = Group.rawValue
            let FilterList = Filters.keys.map({$0.rawValue}).sorted()
            GroupNames.append((GroupName, FilterList))
        }
        GroupNames.sort(by: {$0.0 < $1.0})
        return GroupNames
    }
    
    /// Returns an array of alphabetized filter names.
    /// - Returns: Array of all known filter names, alphabetized.
    public static func AlphabetizedFilterNames() -> [String]
    {
        let NameArray = BuiltInFilterMap.keys.map({$0.rawValue}).sorted()
        return NameArray
    }
}
