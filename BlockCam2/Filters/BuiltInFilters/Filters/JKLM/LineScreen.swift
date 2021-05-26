//
//  LineScreen.swift
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

class LineScreen: CIFilterBase, BuiltInFilterProtocol
{
    static var FilterType: BuiltInFilters = .LineScreen
    
    var NeedsInitialization: Bool = false
    
    func Initialize(With FormatDescription: CMFormatDescription, BufferCountHint: Int)
    {
    }
    
    func RunFilter(_ Buffer: [CVPixelBuffer], _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace, Options: [FilterOptions: Any]) -> CVPixelBuffer
    {
        let SourceImage = CIImage(cvImageBuffer: Buffer.first!)
        super.CreateBufferPool(Source: SourceImage, From: Buffer.first!)
        let Adjust = CIFilter.lineScreen()
        var FinalAngle = Options[.Angle] as? Double ?? 0.0
        FinalAngle = FinalAngle * Double.pi / 180.0
        Adjust.angle = Float(FinalAngle)
        Adjust.center = Options[.Center] as? CGPoint ?? CGPoint(x: SourceImage.extent.width / 2.0,
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
        Settings.SetDouble(.LineScreenAngle, Settings.SettingDefaults[.LineScreenAngle] as! Double)
    }
    
    /// Returns the initial preset angle for the setting segment control. If the angle does not equal
    /// a preset value, 0 is returned.
    /// - Returns: Angle to use for the preset segment control for the line screen angle.
    public static func GetInitialPresetAngle() -> Int
    {
        let Current = Settings.GetDouble(.LineScreenAngle, 0.0)
        if Current == 0.0
        {
            return 0
        }
        if Current == 45.0
        {
            return 45
        }
        if Current == 90.0
        {
            return 90
        }
        if Current == 135.0
        {
            return 135
        }
        return 0
    }
}
