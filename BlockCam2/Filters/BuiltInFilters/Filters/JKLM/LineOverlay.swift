//
//  LineOverlay.swift
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

class LineOverlay: CIFilterBase, BuiltInFilterProtocol
{
    static var FilterType: BuiltInFilters = .LineOverlay
    
    var NeedsInitialization: Bool = false
    
    func Initialize(With FormatDescription: CMFormatDescription, BufferCountHint: Int)
    {
    }
    
    func RunFilter(_ Buffer: [CVPixelBuffer], _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace, Options: [FilterOptions: Any]) -> CVPixelBuffer
    {
        let SourceImage = CIImage(cvImageBuffer: Buffer.first!)
        super.CreateBufferPool(Source: SourceImage, From: Buffer.first!)
        let Adjust = CIFilter.lineOverlay()
        Adjust.edgeIntensity = Float(Options[.EdgeIntensity] as? Double ?? 5.0)
        Adjust.contrast = Float(Options[.Contrast] as? Double ?? 5.0)
        Adjust.threshold = Float(Options[.Threshold] as? Double ?? 0.0)
        Adjust.nrNoiseLevel = Float(Options[.NRNoiseLevel] as? Double ?? 0.07)
        Adjust.nrSharpness = Float(Options[.NRSharpness] as? Double ?? 5.0)
        Adjust.inputImage = SourceImage
        if let Filtered = Adjust.inputImage
        {
            if let Merged = FilterHelper.Merge(Filtered, SourceImage)
            {
                var PixBuf: CVPixelBuffer? = nil
                CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, super.BasePool!, &PixBuf)
                guard let OutPixBuf = PixBuf else
                {
                    fatalError("Allocation failure in \(#function)")
                }
                CIContext().render(Merged, to: OutPixBuf, bounds: SourceImage.extent,
                                   colorSpace: ColorSpace)
                return OutPixBuf
            }
        }
        return Buffer.first!
    }
    
    /// Reset the filter's settings.
    static func ResetFilter()
    {
    }
}
