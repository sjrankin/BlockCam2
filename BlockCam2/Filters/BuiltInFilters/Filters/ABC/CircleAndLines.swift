//
//  CircleAndLines.swift
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

class CircleAndLines: BuiltInFilterProtocol
{
    static var FilterType: BuiltInFilters = .CircleAndLines
    
    var NeedsInitialization: Bool = false
    
    func Initialize(With FormatDescription: CMFormatDescription, BufferCountHint: Int)
    {
    }
    
    func RunFilter(_ Buffer: CVPixelBuffer, _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace, Options: [FilterOptions: Any]) -> CVPixelBuffer
    {
        let Circles = CircularScreen()
        let Lines = LineScreen()
        let CircleBuffer = Circles.RunFilter(Buffer, BufferPool, ColorSpace, Options: [:])
        let LineBuffer = Lines.RunFilter(CircleBuffer, BufferPool, ColorSpace, Options: [:])
        return LineBuffer
    }
}
