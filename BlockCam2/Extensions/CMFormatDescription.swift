//
//  CMFormatDescription.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/5/21.
//

import Foundation
import UIKit
import CoreImage
import CoreMedia

//https://qiita.com/noppefoxwolf/items/12ddee8e9c8457962ff6
extension CMFormatDescription
{
    static func make(from pixelBuffer: CVPixelBuffer) -> CMFormatDescription?
    {
        var formatDescription: CMFormatDescription?
        CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: pixelBuffer, formatDescriptionOut: &formatDescription)
        return formatDescription
    }
}
