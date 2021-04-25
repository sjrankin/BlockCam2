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
    
    static var Name: String = "Line Screen Blend"
    
    func RunFilter(_ Buffer: CVPixelBuffer, _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace, Options: [FilterOptions: Any]) -> CVPixelBuffer
    {
        let Lines = LineScreen()
        let LineBuffer = Lines.RunFilter(Buffer, BufferPool, ColorSpace, Options: [:])
        let SourceImage = CIImage(cvPixelBuffer: Buffer)
        if let Merged = FilterHelper.Merge(CIImage(cvPixelBuffer: LineBuffer), SourceImage)
        {
        return FilterHelper.CIImageToCVPixelBuffer(Merged, BufferPool, ColorSpace)
        }
        return Buffer
    }
}
