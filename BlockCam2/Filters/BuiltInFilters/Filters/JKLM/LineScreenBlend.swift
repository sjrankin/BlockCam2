//
//  LineScreenBlend.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/25/21.
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

class LineScreenBlend: CIFilterBase, BuiltInFilterProtocol
{
    static var FilterType: BuiltInFilters = .LineScreenBlend
    
    var NeedsInitialization: Bool = false
    
    func Initialize(With FormatDescription: CMFormatDescription, BufferCountHint: Int)
    {
    }
    
    func RunFilter(_ Buffer: [CVPixelBuffer], _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace, Options: [FilterOptions: Any]) -> CVPixelBuffer
    {
        let Lines = LineScreen()
        let SourceImage = CIImage(cvPixelBuffer: Buffer.first!)
        super.CreateBufferPool(Source: SourceImage, From: Buffer.first!)
        let LineBuffer = Lines.RunFilter(Buffer, super.BasePool!, ColorSpace, Options: [:])
        if let Merged = FilterHelper.Merge(CIImage(cvPixelBuffer: LineBuffer), SourceImage)
        {
            return FilterHelper.CIImageToCVPixelBuffer(Merged, super.BasePool!, ColorSpace)
        }
        return Buffer.first!
    }
    
    /// Reset the filter's settings.
    static func ResetFilter()
    {
    }
}
