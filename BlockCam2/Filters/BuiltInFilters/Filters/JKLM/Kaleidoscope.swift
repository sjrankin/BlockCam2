//
//  Kaleidoscope.swift
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

class Kaleidoscope: CIFilterBase, BuiltInFilterProtocol
{
    static var FilterType: BuiltInFilters = .Kaleidoscope
    
    var NeedsInitialization: Bool = false
    
    func Initialize(With FormatDescription: CMFormatDescription, BufferCountHint: Int)
    {
    }
    
    func RunFilter(_ Buffer: [CVPixelBuffer], _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace, Options: [FilterOptions: Any]) -> CVPixelBuffer
    {
        let SourceImage = CIImage(cvImageBuffer: Buffer.first!)
        super.CreateBufferPool(Source: SourceImage, From: Buffer.first!)
        let Adjust = CIFilter.kaleidoscope()
        Adjust.center = Options[.Center] as? CGPoint ?? CGPoint(x: SourceImage.extent.width / 2.0,
                                                                y: SourceImage.extent.height / 2.0)
        Adjust.inputImage = SourceImage
        Adjust.count = Options[.Count] as? Int ?? 32
        Adjust.angle = Float(Options[.Angle] as? Int ?? 0)
        if let Adjusted = Adjust.outputImage
        {
            var Initial = Adjusted
            if (Options[.BackgroundFill] as? Bool ?? true)
            {
                if let BackgroundImage = UIImage.MakeColorImage(SolidColor: UIColor.black,
                                                                Size: Initial.extent.size)
                {
                    if let FinalBG = CIImage(image: BackgroundImage)
                    {
                        Initial = FilterHelper.Blit(Adjusted, FinalBG)!
                    }
                }
            }
            var PixBuf: CVPixelBuffer? = nil
            CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, super.BasePool!, &PixBuf)
            guard let OutPixBuf = PixBuf else
            {
                Debug.FatalError("Allocation failure in \(#function)")
            }
            CIContext().render(Initial, to: OutPixBuf, bounds: Initial.extent,
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
        Settings.SetInt(.KaleidoscopeSegmentCount,
                        Settings.SettingDefaults[.KaleidoscopeSegmentCount] as! Int)
        Settings.SetInt(.KaleidoscopeAngleOfReflection,
                        Settings.SettingDefaults[.KaleidoscopeAngleOfReflection] as! Int)
        Settings.SetBool(.KaleidoscopeFillBackground,
                         Settings.SettingDefaults[.KaleidoscopeFillBackground] as! Bool)
    }
}
