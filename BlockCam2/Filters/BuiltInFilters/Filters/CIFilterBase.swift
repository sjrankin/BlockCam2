//
//  CIFilterBase.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/8/21.
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

/// Base class for CIFilter-based filters. Provides certain common functionality.
class CIFilterBase
{
    /// Format of the buffer passed to `CreateBufferPool` If nil, no buffer has been passed or there was
    /// an error in the processing of the buffer.
    var BufferFormat: CMFormatDescription? = nil
    
    /// Base pixel buffer pool. If nil, no buffer has been passed or there was an error in the processing
    /// of the buffer.
    var BasePool: CVPixelBufferPool? = nil
    
    /// Size of the previous buffer processed. If nil, no buffer has been processed. This is used to control
    /// when buffer pools are regenerated.
    var PreviousSize: CGSize? = nil
    
    /// Create a buffer pool based on the passed pixel buffer.
    /// - Note: This function will create a buffer pool (available as `super.BasePool`) only when the dimensions
    ///         of the passed pixel buffer are different from the previous dimensions. This is done to help
    ///         increase performance by eliminating unneeded operations.
    /// - Parameter Source: `CIImage` for the buffer pool data. Used to determine the dimensions of
    ///                     the buffer.
    /// - Parameter From: The pixel buffer used to create the pixel buffer pool.
    /// - Parameter Hint: Hint passed to `CreateBufferPool` for the number of buffers in the buffer pool.
    ///                   Defaults to `3`.
    func CreateBufferPool(Source: CIImage, From PixelBuffer: CVPixelBuffer, Hint: Int = 3)
    {
        if let Previous = PreviousSize
        {
            if Source.extent.width == Previous.width && Source.extent.height == Previous.height
            {
                return
            }
        }
        PreviousSize = CGSize(width: Source.extent.width, height: Source.extent.height)
        guard let Format = FilterHelper.GetFormatDescription(From: PixelBuffer) else
        {
            Debug.FatalError("Error getting format description.")
        }
        BasePool = FilterHelper.CreateBufferPool(From: Format,
                                                 BufferCountHint: Hint,
                                                 BufferSize: PreviousSize!)
        guard BasePool != nil else
        {
            Debug.FatalError("Error create base buffer pool.")
        }
    }
    
    /// Create a buffer pool based on the passed pixel buffer.
    /// - Note:
    ///   - This function will create a buffer pool (available as `super.BasePool`) only when the dimensions
    ///         of the passed pixel buffer are different from the previous dimensions. This is done to help
    ///         increase performance by eliminating unneeded operations.
    ///   - This function will create an internal `CIImage` to determine the dimentions of the passed buffer.
    /// - Parameter From: The pixel buffer used to create the pixel buffer pool.
    /// - Parameter Hint: Hint passed to `CreateBufferPool` for the number of buffers in the buffer pool.
    ///                   Defaults to `3`.
    func CreateBufferPool(From PixelBuffer: CVPixelBuffer, Hint: Int = 3)
    {
        let Source = CIImage(cvImageBuffer: PixelBuffer)
        if let Previous = PreviousSize
        {
            if Source.extent.width == Previous.width && Source.extent.height == Previous.height
            {
                return
            }
        }
        PreviousSize = CGSize(width: Source.extent.width, height: Source.extent.height)
        guard let Format = FilterHelper.GetFormatDescription(From: PixelBuffer) else
        {
            Debug.FatalError("Error getting format description.")
        }
        BasePool = FilterHelper.CreateBufferPool(From: Format,
                                                 BufferCountHint: Hint,
                                                 BufferSize: PreviousSize!)
        guard BasePool != nil else
        {
            Debug.FatalError("Error create base buffer pool.")
        }
    }
    
    /// Create a buffer pool based on the passed pixel buffer.
    /// - Note: This function will create a buffer pool (available as `super.BasePool`) only when the dimensions
    ///         of the passed pixel buffer are different from the previous dimensions. This is done to help
    ///         increase performance by eliminating unneeded operations.
    /// - Parameter From: The pixel buffer used to create the pixel buffer pool.
    /// - Parameter With: The dimentions of the pixel buffer.
    /// - Parameter Hint: Hint passed to `CreateBufferPool` for the number of buffers in the buffer pool.
    ///                   Defaults to `3`.
    func CreateBufferPool(From PixelBuffer: CVPixelBuffer, With Size: CGSize, Hint: Int = 3)
    {
        if let Previous = PreviousSize
        {
            if Size.width == Previous.width && Size.height == Previous.height
            {
                return
            }
        }
        PreviousSize = CGSize(width: Size.width, height: Size.height)
        guard let Format = FilterHelper.GetFormatDescription(From: PixelBuffer) else
        {
            Debug.FatalError("Error getting format description.")
        }
        BasePool = FilterHelper.CreateBufferPool(From: Format,
                                                 BufferCountHint: Hint,
                                                 BufferSize: PreviousSize!)
        guard BasePool != nil else
        {
            Debug.FatalError("Error create base buffer pool.")
        }
    }
}
