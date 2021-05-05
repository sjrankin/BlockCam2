//
//  FilterMap.swift
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
        FilterMap[.Threshold] = BlockCam2.Threshold()
        return FilterMap
    }
    
    private static func MakeAdjustmentFilters() -> [BuiltInFilters: BuiltInFilterProtocol]?
    {
        var FilterMap = [BuiltInFilters: BuiltInFilterProtocol]()
        FilterMap[.HueAdjust] = BlockCam2.HueAdjust()
        FilterMap[.ExposureAdjust] = BlockCam2.ExposureAdjust()
        FilterMap[.GammaAdjust] = BlockCam2.GammaAdjust()
        FilterMap[.ColorControls] = BlockCam2.ColorControls()
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
        FilterMap[.GrayscaleInvert] = BlockCam2.GrayscaleInvert()
        return FilterMap
    }
    
    private static func MakeDistortionFilters() -> [BuiltInFilters: BuiltInFilterProtocol]?
    {
        var FilterMap = [BuiltInFilters: BuiltInFilterProtocol]()
        FilterMap[.Posterize] = BlockCam2.Posterize()
        FilterMap[.Pixellate] = BlockCam2.Pixellate()
        FilterMap[.Otsu] = BlockCam2.Otsu()
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
 //       FilterMap[.Mirroring] = BlockCam2.MirroringDistortion()
        FilterMap[.Mirroring2] = BlockCam2.Mirror2()
        FilterMap[.Dilate] = BlockCam2.Dilate()
        FilterMap[.Erode] = BlockCam2.Erode()
        FilterMap[.Median] = BlockCam2.Median()
        FilterMap[.HeightField] = BlockCam2.HeightField()
        FilterMap[.SaliencyMap] = BlockCam2.SaliencyMap()
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
        FilterMap[.LineOverlay] = BlockCam2.LineOverlay()
        FilterMap[.ThermalEffect] = BlockCam2.Thermal()
        FilterMap[.Emboss] = BlockCam2.Emboss()
        FilterMap[.Dither] = BlockCam2.Dither()
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
    
    private static func MakeMultiFrameFilters() -> [BuiltInFilters: BuiltInFilterProtocol]?
    {
        var FilterMap = [BuiltInFilters: BuiltInFilterProtocol]()
        FilterMap[.ImageDelta]  = BlockCam2.ImageDelta()
        return FilterMap
    }
    
    private static func MakeEdgeFilters() -> [BuiltInFilters: BuiltInFilterProtocol]?
    {
        var FilterMap = [BuiltInFilters: BuiltInFilterProtocol]()
        FilterMap[.GaborGradients] = BlockCam2.GaborGradients()
        FilterMap[.Sobel] = BlockCam2.Sobel()
        FilterMap[.SobelBlend] = BlockCam2.SobelBlend()
        FilterMap[.Edges] = BlockCam2.Edges()
        FilterMap[.EdgeWork] = BlockCam2.EdgeWork()
        FilterMap[.Lapacian] = BlockCam2.MPSLaplacian()
        FilterMap[.MorphologyGradient] = BlockCam2.MorphologyGradient()
        return FilterMap
    }
    
    private static func MakeTestFilters() -> [BuiltInFilters: BuiltInFilterProtocol]?
    {
        var FilterMap = [BuiltInFilters: BuiltInFilterProtocol]()
        FilterMap[.Crop] = BlockCam2.Crop()
        FilterMap[.Crop2] = BlockCam2.Crop2()
        FilterMap[.Reflect] = BlockCam2.Reflect()
        FilterMap[.QuadrantTest] = BlockCam2.QuadrantTest()
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
                case .MultiFrame:
                    FilterData = MakeMultiFrameFilters()
                
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
                    
                case .Edges:
                    FilterData = MakeEdgeFilters()
                    
                case .Test:
                    FilterData = MakeTestFilters()
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

/// Used to specify optional values for filters. Interpretation of filter options depends on the individual
/// filter.
enum FilterOptions: String
{
    case Radius = "Radius"
    case Center = "Center"
    case Angle = "Angle"
    case Scale = "Scale"
    case Zoom = "Zoom"
    case Rotation = "Roation"
    case Periodicity = "Periodicity"
    case Sharpness = "Sharpness"
    case Width = "Width"
    case Height = "Height"
    case ExposureValue = "ExposureValue"
    case Color = "Color"
    case Color0 = "Color0"
    case Color1 = "Color1"
    case LowColor = "LowColor"
    case HighColor = "HighColor"
    case GrayscaleFilter = "GrayscaleFilter"
    case Count = "Count"
    case Contrast = "Contrast"
    case Threshold = "Threshold"
    case ThresholdInput = "ThresholdInput"
    case ApplyIfHigher = "ApplyIfHigher"
    case EdgeIntensity = "EdgeIntensity"
    case NRNoiseLevel = "NRNoiseLevel"
    case NRSharpness = "NRSharpness"
    case Levels = "Levels"
    case Point = "Point"
    case Amount = "Amount"
    case Point1 = "Point1"
    case Point2 = "Point2"
    case Strands = "Strands"
    case Intensity = "Intensity"
    case Size = "Size"
    case Merge = "Merge"
    case GradientColor0 = "GradientColor0"
    case GradientColor1 = "GradientColor1"
    case GradientPoint0 = "GradientPoint0"
    case GradientPoint1 = "GradientPoint1"
    case GradientDefinition = "GradientDefinition"
    case ChainedFilters = "ChainedFilters"
    case ShaderBias = "ShaderBias"
    case ErodeWidth = "ErodeWidth"
    case ErodeHeight = "ErodeHeight"
    case DilateWidth = "DilateWidth"
    case DilateHeight = "DilateHeight"
    case EmbossType = "EmbossType"
    case MedianDiameter = "MedianDiameter"
    case DitherIntensity = "DitherIntensity"
    case Power = "Power"
    case Brightness = "Brightness"
    case Saturation = "Saturation"
    case HorizontalMirrorSide = "HorizontalMirrorSide"
    case VerticalMirrorSide = "VerticalMirrorSide"
    case MirrorQuadrant = "MirrorQuadrant"
    case SourceIsAV = "SourceIsAV"
    case Invert = "Invert"
    case Decay = "Decay"
    case FilterName = "FilterName"
}

