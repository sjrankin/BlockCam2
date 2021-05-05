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

class LineScreenBlend: BuiltInFilterProtocol
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
        guard let Format = FilterHelper.GetFormatDescription(From: Buffer.first!) else
        {
            fatalError("Error getting description of buffer in LineScreenBlend.")
        }
        guard let LocalBufferPool = FilterHelper.CreateBufferPool(From: Format,
                                                                  BufferCountHint: 3,
                                                                  BufferSize: CGSize(width: SourceImage.extent.width,
                                                                                     height: SourceImage.extent.height)) else
        {
            fatalError("Error creating local buffer pool in LineScreenBlend.")
        }
        let LineBuffer = Lines.RunFilter(Buffer, LocalBufferPool, ColorSpace, Options: [:])
        if let Merged = FilterHelper.Merge(CIImage(cvPixelBuffer: LineBuffer), SourceImage)
        {
            return FilterHelper.CIImageToCVPixelBuffer(Merged, LocalBufferPool, ColorSpace)
        }
        return Buffer.first!
    }
}
