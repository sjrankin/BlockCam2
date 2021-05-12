//
//  Crop2.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/2/21.
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

class Crop2: CIFilterBase, BuiltInFilterProtocol
{
    static var FilterType: BuiltInFilters = .Crop2
    
    var NeedsInitialization: Bool = false
    
    func Initialize(With FormatDescription: CMFormatDescription, BufferCountHint: Int)
    {
    }
    
    static func RunFilter(_ Buffer: CVPixelBuffer, Options: [FilterOptions: Any]) -> CIImage?
    {
        let SourceImage = CIImage(cvPixelBuffer: Buffer)
        if let Adjust = CIFilter(name: "CICrop")
        {
            Adjust.setValue(SourceImage, forKey: kCIInputImageKey)
            let Vector = CGRect(origin: CGPoint.zero, size: CGSize(width: SourceImage.extent.width / 2.0,
                                                                   height: SourceImage.extent.height / 2.0))
            Adjust.setValue(Vector, forKey: "inputRectangle")
            if let Adjusted = Adjust.outputImage
            {
                return Adjusted
            }
        }
        return nil
    }
    
    func RunFilter(_ Buffer: [CVPixelBuffer], _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace, Options: [FilterOptions: Any]) -> CVPixelBuffer
    {
        let SourceImage = CIImage(cvImageBuffer: Buffer.first!)
        super.CreateBufferPool(Source: SourceImage, From: Buffer.first!)
        if let Adjust = CIFilter(name: "CICrop")
        {
            Adjust.setValue(SourceImage, forKey: kCIInputImageKey)
            let Vector = CGRect(origin: CGPoint.zero, size: CGSize(width: SourceImage.extent.width / 2.0,
                                                                   height: SourceImage.extent.height / 2.0))
            Adjust.setValue(Vector, forKey: "inputRectangle")
            if let Adjusted = Adjust.outputImage
            {
                var PixBuf: CVPixelBuffer? = nil
                CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, super.BasePool!, &PixBuf)
                guard let OutPixBuf = PixBuf else
                {
                    fatalError("Allocation failure in \(#function)")
                }
                CIContext().render(Adjusted, to: OutPixBuf, bounds: Vector,
                                   colorSpace: ColorSpace)
                let test = CIImage(cvPixelBuffer: OutPixBuf)
                return OutPixBuf
            }
            else
            {
                print("No output image available")
                return Buffer.first!
            }
        }
        else
        {
            print("Did not find CICrop")
            return Buffer.first!
        }
    }
    
    /// Reset the filter's settings.
    static func ResetFilter()
    {
    }
}
