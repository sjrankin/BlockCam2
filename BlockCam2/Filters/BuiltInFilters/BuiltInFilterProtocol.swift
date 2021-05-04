//
//  BuiltInFilterProtocol.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/21/21.
//

import Foundation
import CoreMedia

/// Protocol for 2D filters.
protocol BuiltInFilterProtocol
{
    /// Returns the type of filter.
    static var FilterType: BuiltInFilters {get}

    /// Tells the caller if the class' `Initialization` function should be called.
    var NeedsInitialization: Bool {get}
    
    /// Description of the intialization function for filters that require it. For filters that do not require
    /// this function, it is ignored if called.
    func Initialize(With FormatDescription: CMFormatDescription, BufferCountHint: Int)
    
    /// Run the filter.
    /// - Parameter Buffer: Array of source image pixel buffers. Most filters use only the first image buffer.
    /// - Parameter BufferPool: Managed buffer pool.
    /// - Parameter Colorspace: Current color space.
    /// - Parameter Options: Dictionary of options to use on the filter. For filters that have no options,
    ///                      this parameter is ignored. Missing options will result in default values being
    ///                      used. Incorrect options (as in options the filter does not comprehend) will be
    ///                      ignored. Set to `[:]` to use all default values.
    func RunFilter(_ Buffer: [CVPixelBuffer],
                   _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace,
                   Options: [FilterOptions: Any]) -> CVPixelBuffer
    
    #if false
    /// Run the filter.
    /// - Note: Options are populated from user settings and passed to the polymorphic
    ///         function that does that actual processing.
    /// - Parameter Buffer: Array of source image pixel buffers. Most filters use only the first image buffer.
    /// - Parameter BufferPool: Managed buffer pool.
    /// - Parameter Colorspace: Current color space.
    func RunFilter(_ Buffer: [CVPixelBuffer],
                   _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace) -> CVPixelBuffer
    #endif
}
