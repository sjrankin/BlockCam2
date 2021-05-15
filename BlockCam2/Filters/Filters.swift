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
        let LastFilterName = Settings.GetString(.CurrentFilter, "")
        if let LastSaved = BuiltInFilters(rawValue: LastFilterName)
        {
            LastBuiltInFilterUsed = LastSaved
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
            Error = CVPixelBufferPoolCreatePixelBufferWithAuxAttributes(kCFAllocatorDefault, Pool,
                                                                        AuxAttributes, &PixelBuffer)
            if let PixelBuffer = PixelBuffer
            {
                PixelBuffers.append(PixelBuffer)
            }
            PixelBuffer = nil
        }
        PixelBuffers.removeAll()
    }
    
    static var BufferPool: CVPixelBufferPool? = nil
    
    /// Returns a dictionary of options for the passed filter.
    /// - Note: Values in the `Settings` system are used to populate the returned dictionary. If a given
    ///          filter does not have any options, an empty dictionary is returned.
    /// - Parameter For: The filter whose option dictionary is populated with `Settings` values.
    /// - Returns: Dictionary of options for the passed filter. May be empty if a given filter does not have
    ///            any options.
    public static func GetOptions(For Filter: BuiltInFilters) -> [FilterOptions: Any]
    {
        var Options = [FilterOptions: Any]()
        switch Filter
        {
            case .Convolution:
                Options[.Bias] = Settings.GetDouble(.ConvolutionBias,
                                                    Settings.SettingDefaults[.ConvolutionBias] as! Double)
                Options[.Width] = Settings.GetInt(.ConvolutionWidth,
                                                  IfZero: Settings.SettingDefaults[.ConvolutionWidth] as! Int)
                Options[.Height] = Settings.GetInt(.ConvolutionHeight,
                                                   IfZero: Settings.SettingDefaults[.ConvolutionHeight] as! Int)
                Options[.Matrix] = Settings.GetMatrix(.ConvolutionKernel,
                                                      CreateIfEmpty: true) ??
                    Settings.SettingDefaults[.ConvolutionKernel] as! [[Double]]
            
            case .Threshold:
                Options[.LowColor] = Settings.GetColor(.ThresholdLowColor,
                                             Settings.SettingDefaults[.ThresholdLowColor] as! UIColor)
                Options[.HighColor] = Settings.GetColor(.ThresholdHighColor,
                                                        Settings.SettingDefaults[.ThresholdHighColor] as! UIColor)
                Options[.ThresholdInput] = Settings.GetInt(.ThresholdInputChannel)
                Options[.ApplyIfHigher] = Settings.GetBool(.ThresholdApplyIfGreater)
                Options[.Threshold] = Settings.GetDouble(.ThresholdValue,
                                                         Settings.SettingDefaults[.ThresholdValue] as! Double)
            
            case .EdgeWork:
                Options[.Intensity] = Settings.GetDouble(.EdgeWorkThickness,
                                                         Settings.SettingDefaults[.EdgeWorkThickness] as! Double)
            
            case .Sepia:
                Options[.Intensity] = Settings.GetDouble(.SepiaIntensity,
                                                         Settings.SettingDefaults[.SepiaIntensity] as! Double)
            
            case .TwirlDistortion:
                Options[.Radius] = Settings.GetDouble(.TwirlRadius,
                                                      Settings.SettingDefaults[.TwirlRadius] as! Double)
                Options[.Angle] = Settings.GetDouble(.TwirlAngle,
                                                      Settings.SettingDefaults[.TwirlAngle] as! Double)
            
            case .ExposureAdjust:
                Options[.ExposureValue] = Settings.GetDouble(.ExposureValue,
                                                             Settings.SettingDefaults[.ExposureValue] as! Double)
            
            case .Edges:
                Options[.Intensity] = Settings.GetDouble(.EdgesIntensity,
                                                         Settings.SettingDefaults[.EdgesIntensity] as! Double)
            
            case .Droste:
                Options[.Strands] = Settings.GetDouble(.DrosteStrands,
                                                       Settings.SettingDefaults[.DrosteStrands] as! Double)
                Options[.Periodicity] = Settings.GetDouble(.DrostePeriodicity,
                                                           Settings.SettingDefaults[.DrostePeriodicity] as! Double)
                Options[.Rotation] = Settings.GetDouble(.DrosteRotation,
                                                        Settings.SettingDefaults[.DrosteRotation] as! Double)
                Options[.Zoom] = Settings.GetDouble(.DrosteZoom,
                                                    Settings.SettingDefaults[.DrosteZoom] as! Double)
            
            case .Dither:
                Options[.DitherIntensity] = Settings.GetDouble(.DitherIntensity,
                                                         Settings.SettingDefaults[.DitherIntensity] as! Double)
            
            case .DotScreen:
                Options[.Sharpness] = Settings.GetDouble(.DotScreenSharpness,
                                                         Settings.SettingDefaults[.DotScreenSharpness] as! Double)
                Options[.Width] = Settings.GetDouble(.DotScreenWidth,
                                                     Settings.SettingDefaults[.DotScreenWidth] as! Double)
                Options[.Angle] = Settings.GetDouble(.DotScreenAngle,
                                                     Settings.SettingDefaults[.DotScreenAngle] as! Double)
                
            case .CMYKHalftone:
                Options[.Sharpness] = Settings.GetDouble(.CMYKHalftoneSharpness,
                                                     Settings.SettingDefaults[.CMYKHalftoneSharpness] as! Double)
                Options[.Width] = Settings.GetDouble(.CMYKHalftoneWidth,
                                                    Settings.SettingDefaults[.CMYKHalftoneWidth] as! Double)
                Options[.Angle] = Settings.GetDouble(.CMYKHalftoneAngle,
                                                     Settings.SettingDefaults[.CMYKHalftoneAngle] as! Double)
            
            case .CircleSplashDistortion:
                Options[.Radius] = Settings.GetDouble(.CircleSplashDistortionRadius,
                                                      Settings.SettingDefaults[.CircleSplashDistortionRadius] as! Double)
            
            case .ColorMonochrome:
                Options[.Color] = Settings.GetColor(.ColorMonochromeColor)
                
            case .ColorMap:
                Options[.Color0] = Settings.GetColor(.ColorMapColor1)
                Options[.Color1] = Settings.GetColor(.ColorMapColor2)

            case .HueAdjust:
                Options[.Angle] = Settings.GetDouble(.HueAngle, 0.0)
                
            case .Kaleidoscope:
                Options[.Count] = Settings.GetInt(.KaleidoscopeSegmentCount)
                Options[.Angle] = Settings.GetInt(.KaleidoscopeAngleOfReflection)
                Options[.BackgroundFill] = Settings.GetBool(.KaleidoscopeFillBackground) 

            case .TriangleKaleidoscope:
                Options[.Size] = Settings.GetDouble(.Kaleidoscope3Size,
                                                    Settings.SettingDefaults[.Kaleidoscope3Size] as! Double)
                Options[.Angle] = Settings.GetDouble(.Kaleidoscope3Rotation,
                                                     Settings.SettingDefaults[.Kaleidoscope3Rotation] as! Double)
                Options[.Decay] = Settings.GetDouble(.Kaleidoscope3Decay,
                                                     Settings.SettingDefaults[.Kaleidoscope3Decay] as! Double)
                
            case .BumpDistortion:
                Options[.Radius] = Settings.GetDouble(.BumpDistortionRadius,
                                                      Settings.SettingDefaults[.BumpDistortionRadius] as! Double)
                Options[.Scale] = Settings.GetDouble(.BumpDistortionScale,
                                                      Settings.SettingDefaults[.BumpDistortionScale] as! Double)
                
            case .Vibrance:
                Options[.Amount] = Settings.GetDouble(.VibranceAmount,
                                                      Settings.SettingDefaults[.VibranceAmount] as! Double)
                
            case .ColorControls:
                Options[.Brightness] = Settings.GetDouble(.ColorControlsBrightness,
                                                          Settings.SettingDefaults[.ColorControlsBrightness] as! Double)
                Options[.Contrast] = Settings.GetDouble(.ColorControlsBrightness,
                                                          Settings.SettingDefaults[.ColorControlsContrast] as! Double)
                Options[.Saturation] = Settings.GetDouble(.ColorControlsBrightness,
                                                          Settings.SettingDefaults[.ColorControlsSaturation] as! Double)
                
            case .UnsharpMask:
                Options[.Intensity] = Settings.GetDouble(.UnsharpIntensity,
                                                         Settings.SettingDefaults[.UnsharpIntensity] as! Double)
                Options[.Radius] = Settings.GetDouble(.UnsharpRadius,
                                                         Settings.SettingDefaults[.UnsharpRadius] as! Double)
                
            default:
                break
        }
        return Options
    }
    
    public static func BufferToUIImage(_ Buffer: CVPixelBuffer) -> UIImage?
    {
        let CImg = CIImage(cvImageBuffer: Buffer)
        let Img = UIImage(ciImage: CImg)
        return Img
    }
    
    /// Run a built-in filter on the passed image.
    /// - Parameter On: The image on which to run the filter.
    /// - Parameter Filter: The filter to use on the image. If this parameter is nil, the current
    ///                     filter will be used.
    /// - Parameter ReturnOriginalOnError: If true, the original image is returned on error. If false,
    ///                                    nil is returned on error.
    /// - Returns: New and filtered `UIImage` on success, nil on error.
    public static func RunFilter(On Image: UIImage,
                                 Filter: BuiltInFilters? = nil,
                                 ReturnOriginalOnError: Bool = true) -> UIImage?
    {
        if let CImg = CIImage(image: Image)
        {
            var Buffer: CVPixelBuffer?
            let Attributes = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                              kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue,
                              kCVPixelBufferMetalCompatibilityKey: kCFBooleanTrue] as CFDictionary
            CVPixelBufferCreate(kCFAllocatorDefault,
                                Int(Image.size.width),
                                Int(Image.size.height),
                                kCVPixelFormatType_32BGRA,
                                Attributes,
                                &Buffer)
            let Context = CIContext()
            guard let ActualBuffer = Buffer else
            {
                Debug.Print("Error creating buffer")
                return Image
            }
            Context.render(CImg, to: ActualBuffer)
            
//            if let NewBuffer = RunFilter(Filter, With: ActualBuffer)
            if let NewBuffer = RunFilter(With: ActualBuffer, Filter)
            {
                let FinalImage = UIImage(Buffer: NewBuffer)
                return FinalImage
            }
            if ReturnOriginalOnError
            {
                Debug.Print("Returning original image due to processing error: \(#function)")
                return Image
            }
        }
        return nil
    }

    /// Run a built-in filter on the passed buffer.
    /// - Parameter With: The buffer to filter.
    /// - Parameter Filter: The filter to use. If nil, the last used filter is used. If no filter was used
    ///                     prior to this call, `.Passthrough` is used.
    /// - Returns: Filtered data according to `Filter`. Nil on error.
    public static func RunFilter(With Buffer: CVPixelBuffer, _ Filter: BuiltInFilters? = nil) -> CVPixelBuffer?
    {
        if Filter == nil && LastBuiltInFilterUsed == nil
        {
            return Filters.RunFilter(With: Buffer, .Passthrough)
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
            #if targetEnvironment(simulator)
            guard let Format = FilterHelper.GetFormatDescription(From: Buffer) else
            {
                fatalError("Error getting description of buffer in \(#function).")
            }
            guard let LocalBufferPool = FilterHelper.CreateBufferPool(From: Format,
                                                                      BufferCountHint: 3,
                                                                      BufferSize: CGSize(width: Int(Format.dimensions.width),
                                                                                         height: Int(Format.dimensions.height))) else
            {
                fatalError("Error creating local buffer pool in \(#function).")
            }
            FilterInTree.Initialize(With: Format, BufferCountHint: 3)
            let FinalOptions = GetOptions(For: FilterToUse)
            let FinalBuffer = FilterInTree.RunFilter([Buffer],
                                                     LocalBufferPool,
                                                     CGColorSpaceCreateDeviceRGB(),
                                                     Options: FinalOptions)
            #else
            guard let Format = FilterHelper.GetFormatDescription(From: Buffer) else
            {
                fatalError("Error getting description of buffer in \(#function).")
            }
                FilterInTree.Initialize(With: Format, BufferCountHint: 3)
//            FilterInTree.Initialize(With: OutFormatDesc!, BufferCountHint: 3)
            let FinalOptions = GetOptions(For: FilterToUse)
            let FinalBuffer = FilterInTree.RunFilter([Buffer], BufferPool!, ColorSpace!,
                                                     Options: FinalOptions)
            #endif
            return FinalBuffer
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
            .MultiFrame: 0xea71c6,
            .Test: 0xffe0d0,
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
    case Test = "Test/Debug"
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
//    case Mirroring = "Mirroring"
    case Mirroring2 = "Mirroring 2"
    case Threshold = "Threshold"
    case Laplacian = "Laplacian"
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
    case HSB = "HSB"
    case ThresholdInput = "Threshold Input"
    case ApplyIfGreater = "Apply If Greater"
    case LowColor = "Low Color"
    case HighColor = "High Color"
    case AreaMax = "Area Max"
    case Convolution = "Convolution"
    
    //Internal filters
    case Crop = "Crop"
    case Crop2 = "Crop2"
    case Reflect = "Reflect"
    case QuadrantTest = "Quadrant Test"
    case MatrixTest = "Matrix Test"
    
    //3D Filters
    case Blocks = "Blocks"
    case Spheres = "Spheres"
}
