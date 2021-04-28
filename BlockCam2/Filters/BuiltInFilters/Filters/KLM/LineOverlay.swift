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

class LineOverlay: BuiltInFilterProtocol
{
    static var FilterType: BuiltInFilters = .LineOverlay
    
    var NeedsInitialization: Bool = false
    
    func Initialize(With FormatDescription: CMFormatDescription, BufferCountHint: Int)
    {
    }
    
    func RunFilter(_ Buffer: CVPixelBuffer, _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace, Options: [FilterOptions: Any]) -> CVPixelBuffer
    {
        let SourceImage = CIImage(cvImageBuffer: Buffer)
        let Adjust = CIFilter.lineOverlay()
        Adjust.edgeIntensity = Options[.EdgeIntensity] as? Float ?? 5.0
        Adjust.contrast = Options[.Contrast] as? Float ?? 5.0
        Adjust.threshold = Options[.Threshold] as? Float ?? 0.0
        Adjust.nrNoiseLevel = Options[.NRNoiseLevel] as? Float ?? 0.07
        Adjust.nrSharpness = Options[.NRSharpness] as? Float ?? 5.0
        Adjust.inputImage = SourceImage
        if let Filtered = Adjust.inputImage
        {
            if let Merged = FilterHelper.Merge(Filtered, SourceImage)
            {
                var PixBuf: CVPixelBuffer? = nil
                CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, BufferPool, &PixBuf)
                guard let OutPixBuf = PixBuf else
                {
                    fatalError("Allocation failure in \(#function)")
                }
                CIContext().render(Merged, to: OutPixBuf, bounds: SourceImage.extent,
                                   colorSpace: ColorSpace)
                return OutPixBuf
            }
        }
        return Buffer
    }
}
