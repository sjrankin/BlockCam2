//
//  CMSampleBuffer.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/5/21.
//

import Foundation
import UIKit
import CoreImage
import CoreMedia

//https://qiita.com/noppefoxwolf/items/12ddee8e9c8457962ff6
extension CMSampleBuffer
{
    static func make(from pixelBuffer: CVPixelBuffer, formatDescription: CMFormatDescription, timingInfo: inout CMSampleTimingInfo) -> CMSampleBuffer?
    {
        var sampleBuffer: CMSampleBuffer?
        CMSampleBufferCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: pixelBuffer, dataReady: true, makeDataReadyCallback: nil,
                                           refcon: nil, formatDescription: formatDescription, sampleTiming: &timingInfo, sampleBufferOut: &sampleBuffer)
        return sampleBuffer
    }
}
