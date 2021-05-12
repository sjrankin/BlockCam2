//
//  QuadrantTest.swift
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

class QuadrantTest: BuiltInFilterProtocol
{
    static var FilterType: BuiltInFilters = .QuadrantTest
    
    var NeedsInitialization: Bool = false
    
    func Initialize(With FormatDescription: CMFormatDescription, BufferCountHint: Int)
    {
    }
    
    func RunFilter(_ Buffer: [CVPixelBuffer], _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace, Options: [FilterOptions: Any]) -> CVPixelBuffer
    {
        let C = Crop2().RunFilter(Buffer, BufferPool, ColorSpace, Options: Options)
        let test = CIImage(cvPixelBuffer: C)
        return C
        if let CroppedImage = Crop2.RunFilter(Buffer.first!, Options: Options)
        {
            if let PixBuf = MetalFilterParent.GetPixelBufferFrom(CroppedImage)
            {
                let Final = Filters.RunFilter(.Reflect, With: PixBuf)//, Options: Options)
                return Final!
            }
            else
            {
                fatalError("GetPixelBufferFrom returned nil")
            }
        }
        return Buffer.first!
    }
    
    /// Reset the filter's settings.
    static func ResetFilter()
    {
    }
}
