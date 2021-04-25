//
//  ThermalEffect.swift
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

class Thermal: BuiltInFilterProtocol
{
    static var FilterType: BuiltInFilters = .ThermalEffect
    
    static var Name: String = "Thermal"
    
    func RunFilter(_ Buffer: CVPixelBuffer, _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace) -> CVPixelBuffer
    {
        let SourceImage = CIImage(cvImageBuffer: Buffer)
        if let Adjust = CIFilter(name: "CIThermal")
        {
            Adjust.setValue(SourceImage, forKey: kCIInputImageKey)
            if let Adjusted = Adjust.outputImage
            {
                var PixBuf: CVPixelBuffer? = nil
                CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, BufferPool, &PixBuf)
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
                return Buffer
            }
        }
        else
        {
            return Buffer
        }
    }
    
    func RunFilter(_ Buffer: CVPixelBuffer, _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace, Options: [FilterOptions: Any]) -> CVPixelBuffer
    {
        let SourceImage = CIImage(cvImageBuffer: Buffer)
        if let Adjust = CIFilter(name: "CIThermal")
        {
            Adjust.setValue(SourceImage, forKey: kCIInputImageKey)
            if let Adjusted = Adjust.outputImage
            {
                var PixBuf: CVPixelBuffer? = nil
                CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, BufferPool, &PixBuf)
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
                return Buffer
            }
        }
        else
        {
            return Buffer
        }
    }
}
