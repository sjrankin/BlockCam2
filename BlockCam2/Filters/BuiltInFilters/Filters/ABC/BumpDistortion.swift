//
//  BumpDistortion.swift
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

class BumpDistortion: CIFilterBase, BuiltInFilterProtocol
{
    static var FilterType: BuiltInFilters = .BumpDistortion
    
    var NeedsInitialization: Bool = false
    
    func Initialize(With FormatDescription: CMFormatDescription, BufferCountHint: Int)
    {
    }
    
    func RunFilter(_ Buffer: [CVPixelBuffer], _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace, Options: [FilterOptions: Any]) -> CVPixelBuffer
    {
        let SourceImage = CIImage(cvImageBuffer: Buffer.first!)
        CreateBufferPool(Source: SourceImage, From: Buffer.first!)
        let Adjust = CIFilter.bumpDistortion()
        Adjust.radius = Float(Options[.Radius] as? Double ?? 350.0)
        Adjust.scale = Float(Options[.Scale] as? Double ?? 0.65)
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
        Settings.SetDouble(.BumpDistortionScale,
                           Settings.SettingDefaults[.BumpDistortionScale] as! Double)
        Settings.SetDouble(.BumpDistortionRadius,
                           Settings.SettingDefaults[.BumpDistortionRadius] as! Double)
    }
}
