//
//  Droste.swift
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

class Droste: BuiltInFilterProtocol
{
    static var FilterType: BuiltInFilters = .Droste
    
    static var Name: String = "Droste"
    
    func RunFilter(_ Buffer: CVPixelBuffer, _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace) -> CVPixelBuffer
    {
        let SourceImage = CIImage(cvImageBuffer: Buffer)
        let Adjust = CIFilter.droste()
        Adjust.insetPoint0 = CGPoint(x: SourceImage.extent.width * 0.3,
                                     y: SourceImage.extent.height * 0.3)
        Adjust.insetPoint1 = CGPoint(x: SourceImage.extent.width * 0.67,
                                     y: SourceImage.extent.height * 0.67)
        Adjust.strands = Float(2)
        Adjust.periodicity = Float(2)
        Adjust.rotation = Float(35.0)
        Adjust.zoom = Float(1.0)
        Adjust.inputImage = SourceImage
        if let Adjusted = Adjust.outputImage
        {
            var PixBuf: CVPixelBuffer? = nil
            CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, BufferPool, &PixBuf)
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
            return Buffer
        }
    }
    
    func RunFilter(_ Buffer: CVPixelBuffer, _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace, Options: [FilterOptions: Any]) -> CVPixelBuffer
    {
        let SourceImage = CIImage(cvImageBuffer: Buffer)
        let Adjust = CIFilter.droste()
        Adjust.insetPoint0 = Options[.Point1] as? CGPoint ?? CGPoint(x: SourceImage.extent.width * 0.3,
                                     y: SourceImage.extent.height * 0.3)
        Adjust.insetPoint1 = Options[.Point2] as? CGPoint ?? CGPoint(x: SourceImage.extent.width * 0.67,
                                     y: SourceImage.extent.height * 0.67)
        Adjust.strands = Options[.Strands] as? Float ?? Float(2)
        Adjust.periodicity = Options[.Periodicity] as? Float ?? Float(2)
        Adjust.rotation = Options[.Rotation] as? Float ?? Float(35.0)
        Adjust.zoom = Options[.Zoom] as? Float ?? Float(1.0)
        Adjust.inputImage = SourceImage
        if let Adjusted = Adjust.outputImage
        {
            var PixBuf: CVPixelBuffer? = nil
            CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, BufferPool, &PixBuf)
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
            return Buffer
        }
    }
}
