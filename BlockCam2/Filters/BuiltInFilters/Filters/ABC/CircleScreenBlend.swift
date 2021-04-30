//
//  CircleScreenBlend.swift
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

class CircleScreenBlend: BuiltInFilterProtocol
{
    static var FilterType: BuiltInFilters = .CircleScreenBlend
    
    var NeedsInitialization: Bool = false
    
    func Initialize(With FormatDescription: CMFormatDescription, BufferCountHint: Int)
    {
    }
    
    func RunFilter(_ Buffer: [CVPixelBuffer], _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace, Options: [FilterOptions: Any]) -> CVPixelBuffer
    {
        let Lines = CircularScreen()
        let LineBuffer = Lines.RunFilter(Buffer, BufferPool, ColorSpace, Options: [:])
        let SourceImage = CIImage(cvPixelBuffer: Buffer.first!)
        if let Merged = FilterHelper.Merge(CIImage(cvPixelBuffer: LineBuffer), SourceImage)
        {
            return FilterHelper.CIImageToCVPixelBuffer(Merged, BufferPool, ColorSpace)
        }
        return Buffer.first!
    }
}
