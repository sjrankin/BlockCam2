//
//  HistogramDisplay.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/22/21.
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

class HistogramDisplay: CIFilterBase, BuiltInFilterProtocol
{
    static var FilterType: BuiltInFilters = .HistogramDisplay
    
    var NeedsInitialization: Bool = false
    
    func Initialize(With FormatDescription: CMFormatDescription, BufferCountHint: Int)
    {
    }
    
    func RunFilter(_ Buffer: [CVPixelBuffer], _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace, Options: [FilterOptions: Any]) -> CVPixelBuffer
    {
        let Initial = CIImage(cvImageBuffer: Buffer.first!)
        super.CreateBufferPool(Source: Initial, From: Buffer.first!)
        let AreaHisto = AreaHistogram()
        let Histo1D = AreaHisto.RunFilter(Buffer, BufferPool, ColorSpace, Options: [:])
        let SourceImage = CIImage(cvImageBuffer: Histo1D)
        let Adjust = CIFilter.histogramDisplay()
        Adjust.inputImage = SourceImage
        Adjust.height = Float(SourceImage.extent.width)
        if let Adjusted = Adjust.outputImage
        {
            var PixBuf: CVPixelBuffer? = nil
            CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, super.BasePool!, &PixBuf)
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
    }
    
    /// Reset the filter's settings.
    static func ResetFilter()
    {
    }
}
