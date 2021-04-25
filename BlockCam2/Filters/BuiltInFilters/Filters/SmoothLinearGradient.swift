//
//  SmoothLinearGradient.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/25/21.
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

class SmoothLinearGradient: BuiltInFilterProtocol
{
    static var FilterType: BuiltInFilters = .SmoothLinearGradient
    
    static var Name: String = "Smooth Linear Gradient"
    
    func RunFilter(_ Buffer: CVPixelBuffer, _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace, Options: [FilterOptions: Any]) -> CVPixelBuffer
    {
        let SourceImage = CIImage(cvPixelBuffer: Buffer)
        let Adjust = CIFilter.smoothLinearGradient()
        Adjust.color0 = Options[.GradientColor0] as? CIColor ?? CIColor.blue
        Adjust.color1 = Options[.GradientColor1] as? CIColor ?? CIColor.black
        Adjust.point0 = Options[.GradientPoint0] as? CGPoint ?? CGPoint(x: SourceImage.extent.width / 2,
                                                                        y: 0)
        Adjust.point1 = Options[.GradientPoint1] as? CGPoint ?? CGPoint(x: SourceImage.extent.width / 2,
                                                                        y: SourceImage.extent.height)
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
