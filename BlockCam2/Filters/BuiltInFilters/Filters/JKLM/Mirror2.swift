//
//  Mirror2.swift
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

class Mirror2: CIFilterBase, BuiltInFilterProtocol
{
    static var FilterType: BuiltInFilters = .Mono
    
    var NeedsInitialization: Bool = false
    
    func Initialize(With FormatDescription: CMFormatDescription, BufferCountHint: Int)
    {
    }
    
    func RunFilter(_ Buffer: [CVPixelBuffer], _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace, Options: [FilterOptions: Any]) -> CVPixelBuffer
    {
        let SourceImage = CIImage(cvImageBuffer: Buffer.first!)
        super.CreateBufferPool(Source: SourceImage, From: Buffer.first!)
        let Adjust = CIFilter.stretchCrop()
        Adjust.inputImage = SourceImage
        Adjust.centerStretchAmount = 0
        Adjust.cropAmount = 1
        //Adjust.size = CGPoint(x: , y: )
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
        Settings.SetInt(.MirrorDirection,
                        Settings.SettingDefaults[.MirrorDirection] as! Int)
        Settings.SetBool(.MirrorLeft,
                         Settings.SettingDefaults[.MirrorLeft] as! Bool)
        Settings.SetBool(.MirrorTop,
                         Settings.SettingDefaults[.MirrorTop] as! Bool)
        Settings.SetInt(.MirrorQuadrant,
                        Settings.SettingDefaults[.MirrorQuadrant] as! Int)
        Settings.SetBool(.QuadrantsRotated,
                         Settings.SettingDefaults[.QuadrantsRotated] as! Bool)
    }
}
