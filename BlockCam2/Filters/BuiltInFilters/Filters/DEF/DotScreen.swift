//
//  DotScreen.swift
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

class DotScreen: BuiltInFilterProtocol
{
    static var FilterType: BuiltInFilters = .DotScreen
    
    var NeedsInitialization: Bool = false
    
    func Initialize(With FormatDescription: CMFormatDescription, BufferCountHint: Int)
    {
    }
    
    func RunFilter(_ Buffer: [CVPixelBuffer], _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace, Options: [FilterOptions: Any]) -> CVPixelBuffer
    {
        let SourceImage = CIImage(cvImageBuffer: Buffer.first!)
        guard let Format = FilterHelper.GetFormatDescription(From: Buffer.first!) else
        {
            fatalError("Error getting description of buffer in DotScreen.")
        }
        guard let LocalBufferPool = FilterHelper.CreateBufferPool(From: Format,
                                                                  BufferCountHint: 3,
                                                                  BufferSize: CGSize(width: SourceImage.extent.width,
                                                                                     height: SourceImage.extent.height)) else
        {
            fatalError("Error creating local buffer pool in DotScreen.")
        }
        let Adjust = CIFilter.dotScreen()
        Adjust.center = Options[.Center] as? CGPoint ?? CGPoint(x: SourceImage.extent.width / 2.0, y: SourceImage.extent.height / 2.0)
        Adjust.inputImage = SourceImage
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
    }
}
