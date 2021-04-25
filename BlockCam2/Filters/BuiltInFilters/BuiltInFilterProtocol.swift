//
//  BuiltInFilterProtocol.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/21/21.
//

import Foundation

/// Protocol for 2D filters.
protocol BuiltInFilterProtocol
{
    /// Returns the type of filter.
    static var FilterType: BuiltInFilters {get}
    
    /// Returns the name of the filter. Deprecated.
    static var Name: String {get}
    
    #if false
    /// Run the filter.
    /// - Note: Default values are used for all filter parameters.
    /// - Parameter Buffer: The source image buffer upon which the filter will be executed.
    /// - Parameter BufferPool: Managed buffer pool.
    /// - Parameter Colorspace: Current color space.
    func RunFilter(_ Buffer: CVPixelBuffer,
                   _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace) -> CVPixelBuffer
    #endif
    
    /// Run the filter.
    /// - Parameter Buffer: The source image buffer upon which the filter will be executed.
    /// - Parameter BufferPool: Managed buffer pool.
    /// - Parameter Colorspace: Current color space.
    /// - Parameter Options: Dictionary of options to use on the filter. For filters that have no options,
    ///                      this parameter is ignored. Missing options will result in default values being
    ///                      used. Incorrect options (as in options the filter does not comprehend) will be
    ///                      ignored. Set to `[:]` to use all default values.
    func RunFilter(_ Buffer: CVPixelBuffer,
                   _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace,
                   Options: [FilterOptions: Any]) -> CVPixelBuffer
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
    case GrayscaleFilter = "GrayscaleFilter"
    case Count = "Count"
    case Contrast = "Contrast"
    case Threshold = "Threshold"
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
    case GradientColor0 = "GradientColor0"
    case GradientColor1 = "GradientColor1"
    case GradientPoint0 = "GradientPoint0"
    case GradientPoint1 = "GradientPoint1"
    case ChainedFilters = "ChainedFilters"
}

