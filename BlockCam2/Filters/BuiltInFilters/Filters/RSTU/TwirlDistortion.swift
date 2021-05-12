//
//  TwirlDistortion.swift
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

class TwirlDistortion: CIFilterBase, BuiltInFilterProtocol
{
    static var FilterType: BuiltInFilters = .TwirlDistortion
    
    var NeedsInitialization: Bool = false
    
    func Initialize(With FormatDescription: CMFormatDescription, BufferCountHint: Int)
    {
    }
    
    func RunFilter(_ Buffer: [CVPixelBuffer], _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace, Options: [FilterOptions: Any]) -> CVPixelBuffer
    {
        let SourceImage = CIImage(cvImageBuffer: Buffer.first!)
        super.CreateBufferPool(Source: SourceImage, From: Buffer.first!)
        let Adjust = CIFilter.twirlDistortion()
        Adjust.center = Options[.Center] as? CGPoint ?? CGPoint(x: SourceImage.extent.width / 2.0,
                                                                y: SourceImage.extent.height / 2.0)
        Adjust.radius = Float(Options[.Radius] as? Double ?? Double((SourceImage.extent.width / 2.0) * 0.85))
        Adjust.angle = Float(Options[.Angle] as? Double ?? Double(Double.pi * 2))
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
        Settings.SetDouble(.TwirlRadius,
                           Settings.SettingDefaults[.TwirlRadius] as! Double)
        Settings.SetDouble(.TwirlAngle,
                           Settings.SettingDefaults[.TwirlAngle] as! Double)
    }
}
