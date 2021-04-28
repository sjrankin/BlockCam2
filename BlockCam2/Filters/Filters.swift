//
//  Filters.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/18/21.
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

/// Class that manages filters for live view and photo output.
class Filters
{
    /// Initialize filter.
    /// - Notes: If already initialized, control is returned immediately.
    public static func InitializeFilters()
    {
        if Initialized
        {
            return
        }
        _Initialized = true
    }
    
    /// Holds the initialized flag.
    private static var _Initialized: Bool = false
    /// Get the initialized flag.
    public static var Initialized: Bool
    {
        get
        {
            return _Initialized
        }
    }
    
    /// Initialize the filter manager.
    /// - Parameter From: The format description for filtering images.
    /// - Parameter Caller: Used for debugging.
    public static func Initialize(From: CMFormatDescription, Caller: String)
    {
        let InputSubType = CMFormatDescriptionGetMediaSubType(From)
        if InputSubType != kCVPixelFormatType_32BGRA
        {
            fatalError("Invalid pixel buffer type \(InputSubType)")
        }
        
        let InputSize = CMVideoFormatDescriptionGetDimensions(From)
        var PixelBufferAttrs: [String: Any] =
            [
                kCVPixelBufferPixelFormatTypeKey as String: UInt(InputSubType),
                kCVPixelBufferWidthKey as String: Int(InputSize.width),
                kCVPixelBufferHeightKey as String: Int(InputSize.height),
                kCVPixelBufferIOSurfacePropertiesKey as String: [:]
            ]
        
        var GColorSpace = CGColorSpaceCreateDeviceRGB()
        if let FromEx = CMFormatDescriptionGetExtensions(From) as Dictionary?
        {
            let ColorPrimaries = FromEx[kCVImageBufferColorPrimariesKey]
            if let ColorPrimaries = ColorPrimaries
            {
                var ColorSpaceProps: [String: AnyObject] = [kCVImageBufferColorPrimariesKey as String: ColorPrimaries]
                if let YCbCrMatrix = FromEx[kCVImageBufferYCbCrMatrixKey]
                {
                    ColorSpaceProps[kCVImageBufferYCbCrMatrixKey as String] = YCbCrMatrix
                }
                if let XferFunc = FromEx[kCVImageBufferTransferFunctionKey]
                {
                    ColorSpaceProps[kCVImageBufferTransferFunctionKey as String] = XferFunc
                }
                PixelBufferAttrs[kCVBufferPropagatedAttachmentsKey as String] = ColorSpaceProps
            }
            if let CVColorSpace = FromEx[kCVImageBufferCGColorSpaceKey]
            {
                GColorSpace = CVColorSpace as! CGColorSpace
            }
            else
            {
                if (ColorPrimaries as? String) == (kCVImageBufferColorPrimaries_P3_D65 as String)
                {
                    GColorSpace = CGColorSpace(name: CGColorSpace.displayP3)!
                }
            }
        }
        ColorSpace = GColorSpace
        
        let PoolAttrs = [kCVPixelBufferPoolMinimumBufferCountKey as String: 3]
        var CVPixBufPool: CVPixelBufferPool?
        CVPixelBufferPoolCreate(kCFAllocatorDefault, PoolAttrs as NSDictionary?,
                                PixelBufferAttrs as NSDictionary?,
                                &CVPixBufPool)
        guard let WorkingBufferPool = CVPixBufPool else
        {
            fatalError("Allocation failure - could not allocate pixel buffer pool.")
        }
        
        PreAllocateBuffers(Pool: WorkingBufferPool, AllocationThreshold: 3)
        
        var PixelBuffer: CVPixelBuffer?
        let AuxAttrs = [kCVPixelBufferPoolAllocationThresholdKey as String: 3] as NSDictionary
        CVPixelBufferPoolCreatePixelBufferWithAuxAttributes(kCFAllocatorDefault, WorkingBufferPool, AuxAttrs, &PixelBuffer)
        if let PixelBuffer = PixelBuffer
        {
            CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: PixelBuffer,
                                                         formatDescriptionOut: &OutFormatDesc)
        }
        PixelBuffer = nil
        BufferPool = WorkingBufferPool
    }
    
    /// Holds the color space.
    private static var ColorSpace: CGColorSpace? = nil
    /// Holds the context.
    public static var Context: CIContext? = nil
    public static var OutFormatDesc: CMFormatDescription?
    
    /// Allocate buffers before use.
    /// - Parameters:
    ///   - Pool: The pool of pixel buffers.
    ///   - AllocationThreshold: Threshold value for allocation.
    static func PreAllocateBuffers(Pool: CVPixelBufferPool, AllocationThreshold: Int)
    {
        var PixelBuffers = [CVPixelBuffer]()
        var Error: CVReturn = kCVReturnSuccess
        let AuxAttributes = [kCVPixelBufferPoolAllocationThresholdKey as String: AllocationThreshold] as NSDictionary
        var PixelBuffer: CVPixelBuffer?
        while Error == kCVReturnSuccess
        {
            Error = CVPixelBufferPoolCreatePixelBufferWithAuxAttributes(kCFAllocatorDefault, Pool, AuxAttributes, &PixelBuffer)
            if let PixelBuffer = PixelBuffer
            {
                PixelBuffers.append(PixelBuffer)
            }
            PixelBuffer = nil
        }
        PixelBuffers.removeAll()
    }
    
    static var BufferPool: CVPixelBufferPool? = nil
    
    /// Run a built-in filter on the passed buffer.
    /// - Parameter Filter: The filter to use. If nil, the last used filter is used. If no filter was used
    ///                     prior to this call, `.Passthrough` is used.
    /// - Parameter With: The buffer to filter.
    /// - Returns: Filtered data according to `Filter`. Nil on error.
    public static func RunFilter(_ Filter: BuiltInFilters? = nil,
                                 With Buffer: CVPixelBuffer) -> CVPixelBuffer?
    {
        if Filter == nil && LastBuiltInFilterUsed == nil
        {
            return Filters.RunFilter(.Passthrough, With: Buffer)
        }
        var FilterToUse: BuiltInFilters = .Passthrough
        if Filter == nil
        {
            FilterToUse = LastBuiltInFilterUsed!
        }
        else
        {
            LastBuiltInFilterUsed = Filter
            FilterToUse = Filter!
        }
        if FilterToUse == .Passthrough
        {
            return Buffer
        }
        if let FilterInTree = Filters.FilterFromTree(FilterToUse)
        {
            FilterInTree.Initialize(With: OutFormatDesc!, BufferCountHint: 3)
            return FilterInTree.RunFilter(Buffer, BufferPool!, ColorSpace!, Options: [:])
        }
        return nil
    }
    
    /// Sets the default filter.
    /// - Parameter NewFilter: Filter to use as the default filter.
    public static func SetFilter(_ NewFilter: BuiltInFilters)
    {
        LastBuiltInFilterUsed = NewFilter
    }
    
    /// Holds the last filter used.
    static var LastBuiltInFilterUsed: BuiltInFilters? = nil
    
    /// Group color data.
    static var GroupData: [FilterGroups: Int] =
        [
            .Adjust: 0x98fb98,
            .Blur: 0x89cff0,
            .Color: 0xffef00,
            .Combined: 0xff9966,
            .Distortion: 0xf88379,
            .Halftone: 0xbc8f8f,
            .Sharpen: 0xddd06a,
            .ThreeD: 0xccccff,
            .Information: 0xfe4eda,
            .Effect: 0xbfff00,
            .Grayscale: 0xbcbcbc,
            .Reset: 0xffffff,
            .Edges: 0xfae6fa,
            .MultiFrame: 0xea71c6
        ]
}

/// High-level filter groups.
enum FilterGroups: String, CaseIterable
{
    case Adjust = "Adjust"
    case Blur = "Blur"
    case Color = "Color"
    case Combined = "Combined"
    case Distortion = "Distortion"
    case Halftone = "Halftone"
    case Effect = "Effect"
    case Sharpen = "Sharpen"
    case ThreeD = "3D"
    case Grayscale = "Grayscale"
    case Information = "Information"
    case Reset = " Reset "
    case Edges = "Edges"
    case MultiFrame = "Frames"
}

/// Individual filters.
enum BuiltInFilters: String, CaseIterable
{
    case Passthrough = "No Filter"
    case LineOverlay = "Line Overlay" 
    case Pixellate = "Pixellate"
    case FalseColor = "False Color"
    case HueAdjust = "Hue"
    case ExposureAdjust = "Exposure"
    case Posterize = "Posterize"
    case Noir = "Noir"
    case LinearTosRGB = "Linear to sRGB"
    case Chrome = "Chrome"
    case Sepia = "Sepia"
    case DotScreen = "Dot Screen"
    case LineScreen = "Line Screen"
    case CircularScreen = "Circular Screen"
    case HatchedScreen = "Hatch Screen"
    case CMYKHalftone = "CMYK Halftone"
    case Instant = "Instant"
    case Fade = "Fade"
    case Mono = "Mono"
    case Process = "Process"
    case Tonal = "Tonal"
    case Transfer = "Transfer"
    case Vibrance = "Vibrance "
    case XRay = "X-Ray"
    case Comic = "Comic"
    case TriangleKaleidoscope = "Triangle Kaleidoscope"
    case Kaleidoscope = "Kaleidoscope"
    case ColorMonochrome = "Color Monochrome"
    case MaximumComponent = "Maximum"
    case MinimumComponent = "Minimum"
    case HistogramDisplay = "Histogram"
    case SharpenLuminance = "Sharpen Luminance"
    case UnsharpMask = "Unsharp Mask"
    case Bloom = "Bloom"
    case Crystallize = "Crystallize"
    case Edges = "Edges"
    case EdgeWork = "Edge Work"
    case Gloom = "Gloom"
    case HexagonalPixellate = "Pixellate Hex"
    case Pointillize = "Pointillize"
    case LinearGradient = "Linear Gradient"
    case SmoothLinearGradient = "Smooth Linear Gradient"
    case ColorMap = "Color Map"
    case MaskToAlpha = "Mask to Alpha"
    case SourceATop = "Source Atop"
    case CircleAndLines = "Circle+Lines"
    case LineScreenBlend = "Lines+BG"
    case CircleScreenBlend = "Circle+BG"
    case ThermalEffect = "Thermal"
    case TwirlDistortion = "Twirl"
    case LightTunnel = "Spiral"
    case HoleDistortion = "Hole"
    case Droste = "Droste"
    case CircleSplashDistortion = "Circle Splash"
    case BumpDistortion = "Bump"
    case AreaHistogram = "Area Histogram"
    case ColorInvert = "Invert"
    case GrayscaleInvert = "B/W Invert"
    case GaussianBlur = "Gaussian"
    case MedianFilter = "Median Old"
    case MotionBlur = "Motion"
    case ZoomBlur = "Zoom"
    case Masking1 = "Masking1"
    case GradientToAlpha = "Gradient->Alpha"
    case AlphaBlend = "AlphaBlend"
    case Mirroring = "Mirroring"
    case Threshold = "Threshold"
    case Lapacian = "Lapacian"
    case Dilate = "Dilate"
    case Emboss = "Emboss"
    case Erode = "Erode"
    case Sobel = "Sobel"
    case SobelBlend = "Sobel+BG"
    case Median = "Median"
    case Otsu = "Otsu"
    case Dither = "Dither"
    case GaborGradients = "Gabor"
    case GammaAdjust = "Gamma"
    case HeightField = "Height Field"
    case SaliencyMap = "Saliency Map"
    case MorphologyGradient = "Morphology"
    case ColorControls = "Control"
    case ConditionalTransparency = "Conditional Transparency"
    case ImageDelta = "Image Delta"
    
    //3D Filters
    case Blocks = "Blocks"
    case Spheres = "Spheres"
}
