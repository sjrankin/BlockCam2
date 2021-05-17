//
//  SlowFilterProtocol.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/17/21.
//

import Foundation
import UIKit
import CoreMedia

protocol SlowFilterProtocol: AnyObject
{
    /// Run the filter. Intended for use by slow, non-real time filters.
    /// - Parameter Buffer: Array of source image pixel buffers. Most filters use only the first image buffer.
    /// - Parameter BufferPool: Managed buffer pool.
    /// - Parameter Colorspace: Current color space.
    /// - Parameter Options: Dictionary of options to use on the filter. For filters that have no options,
    ///                      this parameter is ignored. Missing options will result in default values being
    ///                      used. Incorrect options (as in options the filter does not comprehend) will be
    ///                      ignored. Set to `[:]` to use all default values.
    /// - Parameter Block: Called before control returns but after the processing is complete. Use to be notified
    ///                    when processing has been completed.
    func RunFilter(_ Buffer: [CVPixelBuffer],
                   _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace,
                   Options: [FilterOptions: Any],
                   Block: ((Bool) -> ())?) -> CVPixelBuffer
}
