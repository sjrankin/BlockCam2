//
//  Droste.swift
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

class Droste: CIFilterBase, BuiltInFilterProtocol
{
    static var FilterType: BuiltInFilters = .Droste
    
    var NeedsInitialization: Bool = false
    
    func Initialize(With FormatDescription: CMFormatDescription, BufferCountHint: Int)
    {
    }
    
    func RunFilter(_ Buffer: [CVPixelBuffer], _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace, Options: [FilterOptions: Any]) -> CVPixelBuffer
    {
        let SourceImage = CIImage(cvImageBuffer: Buffer.first!)
        super.CreateBufferPool(Source: SourceImage, From: Buffer.first!)
        let Adjust = CIFilter.droste()
        Adjust.insetPoint0 = Options[.Point1] as? CGPoint ?? CGPoint(x: SourceImage.extent.width * 0.3,
                                                                     y: SourceImage.extent.height * 0.3)
        Adjust.insetPoint1 = Options[.Point2] as? CGPoint ?? CGPoint(x: SourceImage.extent.width * 0.67,
                                                                     y: SourceImage.extent.height * 0.67)
        Adjust.strands = Float(Options[.Strands] as? Double ?? 2.0)
        Adjust.periodicity = Float(Options[.Periodicity] as? Double ?? 2.0)
        Adjust.rotation = Float(Options[.Rotation] as? Double ?? 35.0)
        Adjust.zoom = Float(Options[.Zoom] as? Double ?? 1.0)
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
        Settings.SetDouble(.DrosteStrands,
                           Settings.SettingDefaults[.DrosteStrands] as! Double)
        Settings.SetDouble(.DrostePeriodicity,
                           Settings.SettingDefaults[.DrostePeriodicity] as! Double)
        Settings.SetDouble(.DrosteRotation,
                           Settings.SettingDefaults[.DrosteRotation] as! Double)
        Settings.SetDouble(.DrosteZoom,
                           Settings.SettingDefaults[.DrosteZoom] as! Double)
    }
}
