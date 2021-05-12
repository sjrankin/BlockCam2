//
//  TriangleKaleidoscope.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/22/21.
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

class TriangleKaleidoscope: CIFilterBase, BuiltInFilterProtocol
{
    static var FilterType: BuiltInFilters = .TriangleKaleidoscope
    
    var NeedsInitialization: Bool = false
    
    func Initialize(With FormatDescription: CMFormatDescription, BufferCountHint: Int)
    {
    }
    
    func RunFilter(_ Buffer: [CVPixelBuffer], _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace, Options: [FilterOptions: Any]) -> CVPixelBuffer
    {
        let SourceImage = CIImage(cvImageBuffer: Buffer.first!)
        super.CreateBufferPool(Source: SourceImage, From: Buffer.first!)
        let Adjust = CIFilter.triangleKaleidoscope()
        Adjust.decay = Float(Options[.Decay] as? Double ?? 0.0)
        Adjust.rotation = Float(Options[.Rotation] as? Int ?? 0)
        Adjust.size = Float(Options[.Size] as? Int ?? 300)
        Adjust.point = Options[.Center] as? CGPoint ?? CGPoint(x: SourceImage.extent.width / 2.0,
                                                               y: SourceImage.extent.height / 2.0)
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
        Settings.SetDouble(.Kaleidoscope3Rotation,
                        Settings.SettingDefaults[.Kaleidoscope3Rotation] as! Double)
        Settings.SetDouble(.Kaleidoscope3Size,
                        Settings.SettingDefaults[.Kaleidoscope3Size] as! Double)
        Settings.SetDouble(.Kaleidoscope3Decay,
                           Settings.SettingDefaults[.Kaleidoscope3Decay] as! Double)
    }
}
