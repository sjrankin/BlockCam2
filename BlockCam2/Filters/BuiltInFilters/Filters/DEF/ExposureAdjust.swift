//
//  ExposureAdjust.swift
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

class ExposureAdjust: CIFilterBase, BuiltInFilterProtocol
{
    static var FilterType: BuiltInFilters = .ExposureAdjust
    
    var NeedsInitialization: Bool = false
    
    func Initialize(With FormatDescription: CMFormatDescription, BufferCountHint: Int)
    {
    }
    
    func RunFilter(_ Buffer: [CVPixelBuffer], _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace, Options: [FilterOptions: Any]) -> CVPixelBuffer
    {
        let SourceImage = CIImage(cvImageBuffer: Buffer.first!)
        super.CreateBufferPool(Source: SourceImage, From: Buffer.first!)
        let Adjust = CIFilter.exposureAdjust()
        Adjust.ev = Float(Options[.ExposureValue] as? Double ?? 0.5)
        Adjust.inputImage = SourceImage
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
        Settings.SetDouble(.ExposureValue,
                           Settings.SettingDefaults[.ExposureValue] as! Double)
    }
}
