//
//  CMYKHalftone.swift
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

class CMYKHalftone: CIFilterBase, BuiltInFilterProtocol
{
    static var FilterType: BuiltInFilters = .CMYKHalftone
    
    var NeedsInitialization: Bool = false
    
    func Initialize(With FormatDescription: CMFormatDescription, BufferCountHint: Int)
    {
    }
    
    func RunFilter(_ Buffer: [CVPixelBuffer], _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace, Options: [FilterOptions: Any]) -> CVPixelBuffer
    {
        let SourceImage = CIImage(cvImageBuffer: Buffer.first!)
        super.CreateBufferPool(Source: SourceImage, From: Buffer.first!)
        let Adjust = CIFilter.cmykHalftone()
        Adjust.width = Float(Options[.Width] as? Double ?? 6.0)
        Adjust.sharpness = Float(Options[.Sharpness] as? Double ?? 0.7)
        Adjust.angle = Float(Options[.Angle] as? Double ?? 90.0)
        Adjust.center = CGPoint(x: SourceImage.extent.width / 2.0, y: SourceImage.extent.height / 2.0)
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
        Settings.SetDouble(.CMYKHalftoneWidth,
                           Settings.SettingDefaults[.CMYKHalftoneWidth] as! Double)
        Settings.SetDouble(.CMYKHalftoneSharpness,
                           Settings.SettingDefaults[.CMYKHalftoneSharpness] as! Double)
        Settings.SetDouble(.CMYKHalftoneAngle,
                           Settings.SettingDefaults[.CMYKHalftoneAngle] as! Double)
    }
}
