//
//  ColorMap.swift
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

class ColorMapBad: BuiltInFilterProtocol
{
    static var FilterType: BuiltInFilters = .ColorMap
    
    var NeedsInitialization: Bool = false
    
    func Initialize(With FormatDescription: CMFormatDescription, BufferCountHint: Int)
    {
    }
    
    func RunFilter(_ Buffer: [CVPixelBuffer], _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace, Options: [FilterOptions: Any]) -> CVPixelBuffer
    {
        let SourceImage = CIImage(cvImageBuffer: Buffer.first!)
        #if true
        let GradientImage = FilterHelper.GradientImage(SourceImage.extent,
                                                       Stops: [(UIColor.cyan, 0.0), (UIColor.blue, 1.0)])
        #else
        let Gradient = LinearGradient()
        let GradientOptions =
            [
                FilterOptions.GradientColor0: CIColor.blue,
                FilterOptions.GradientColor1: CIColor.cyan
            ]
        let GradientBuffer = Gradient.RunFilter(Buffer, BufferPool, ColorSpace, Options: GradientOptions)
        let GradientImage = CIImage(cvPixelBuffer: GradientBuffer)
        #endif
        let Adjust = CIFilter.colorMap()
        Adjust.inputImage = SourceImage
        Adjust.gradientImage = GradientImage.ciImage
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
            return Buffer.first!
        }
    }
}
