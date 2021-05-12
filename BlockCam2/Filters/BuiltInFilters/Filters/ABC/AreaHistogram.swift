//
//  AreaHistogram.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/24/21.
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

class AreaHistogram: CIFilterBase, BuiltInFilterProtocol
{
    static var FilterType: BuiltInFilters = .AreaHistogram
    
    var NeedsInitialization: Bool = false
    
    func Initialize(With FormatDescription: CMFormatDescription, BufferCountHint: Int)
    {
    }
    
    func RunFilter(_ Buffer: [CVPixelBuffer], _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace, Options: [FilterOptions: Any]) -> CVPixelBuffer
    {
        let SourceImage = CIImage(cvImageBuffer: Buffer.first!)
        #if true
        super.CreateBufferPool(Source: SourceImage, From: Buffer.first!)
        let Adjust = CIFilter.areaHistogram()
        Adjust.extent = SourceImage.extent
        Adjust.count = Options[.Count] as? Int ?? 256
        Adjust.scale = Options[.Scale] as? Float ?? 1.0
        if let Adjusted = Adjust.outputImage
        {
            var PixBuf: CVPixelBuffer? = nil
            CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, super.BasePool!, &PixBuf)
            guard let OutPixBuf = PixBuf else
            {
                Debug.FatalError("Allocation failure in AreaHistogram.RunFilter")
            }
            CIContext().render(Adjusted, to: OutPixBuf, bounds: SourceImage.extent,
                               colorSpace: ColorSpace)
            return OutPixBuf
        }
        else
        {
            return Buffer.first!
        }
        #else
        guard let Format = FilterHelper.GetFormatDescription(From: Buffer.first!) else
        {
            fatalError("Error getting description of buffer in AreaHistogram.")
        }
        guard let LocalBufferPool = FilterHelper.CreateBufferPool(From: Format,
                                                                  BufferCountHint: 3,
                                                                  BufferSize: CGSize(width: SourceImage.extent.width,
                                                                                     height: SourceImage.extent.height)) else
        {
            fatalError("Error creating local buffer pool in AreaHistogram.")
        }
        let Adjust = CIFilter.areaHistogram()
        Adjust.extent = SourceImage.extent
        Adjust.count = Options[.Count] as? Int ?? 256
        Adjust.scale = Options[.Scale] as? Float ?? 1.0
        if let Adjusted = Adjust.outputImage
        {
            var PixBuf: CVPixelBuffer? = nil
            CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, LocalBufferPool, &PixBuf)
            guard let OutPixBuf = PixBuf else
            {
                fatalError("Allocation failure in \(#function)")
            }
            CIContext().render(Adjusted, to: OutPixBuf, bounds: SourceImage.extent,
                               colorSpace: ColorSpace)
            return OutPixBuf
        }
        else
        {
            return Buffer.first!
        }
        #endif
    }
    
    /// Reset the filter's settings.
    static func ResetFilter()
    {
        
    }
}
