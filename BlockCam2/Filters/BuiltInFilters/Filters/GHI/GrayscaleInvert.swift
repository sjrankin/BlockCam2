//
//  GrayscaleInvert.swift
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

class GrayscaleInvert: BuiltInFilterProtocol
{
    static var FilterType: BuiltInFilters = .GrayscaleInvert
    
    var NeedsInitialization: Bool = false
    
    func Initialize(With FormatDescription: CMFormatDescription, BufferCountHint: Int)
    {
    }
    
    func RunFilter(_ Buffer: [CVPixelBuffer], _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace, Options: [FilterOptions: Any]) -> CVPixelBuffer
    {
        var GrayFilter: BuiltInFilterProtocol? = nil
        let WhichGray = Options[.GrayscaleFilter] as? BuiltInFilters ?? .Noir
        switch WhichGray
        {
            case .Mono:
                GrayFilter = Mono()
                
            case .MaximumComponent:
                GrayFilter = MaximumComponent()
                
            case .MinimumComponent:
                GrayFilter = MinimumComponent()
                
            case .CircularScreen:
                GrayFilter = CircularScreen()
                
            case .LineScreen:
                GrayFilter = LineScreen()
                
            case .DotScreen:
                GrayFilter = DotScreen()
                
            case .HatchedScreen:
                GrayFilter = HatchedScreen()
                
            case .EdgeWork:
                GrayFilter = EdgeWork()
                
            case .Noir:
                GrayFilter = Noir()
                
            default:
                GrayFilter = Noir()
        }
        guard let GrayFilter = GrayFilter else
        {
            return Buffer.first!
        }
        let Initial = CIImage(cvPixelBuffer: Buffer.first!)
        guard let Format = FilterHelper.GetFormatDescription(From: Buffer.first!) else
        {
            fatalError("Error getting description of buffer in HueAdjust.")
        }
        guard let LocalBufferPool = FilterHelper.CreateBufferPool(From: Format,
                                                                  BufferCountHint: 3,
                                                                  BufferSize: CGSize(width: Initial.extent.width,
                                                                                     height: Initial.extent.height)) else
        {
            fatalError("Error creating local buffer pool in HueAdjust.")
        }
        
        let GrayBuffer = GrayFilter.RunFilter(Buffer, LocalBufferPool, ColorSpace, Options: [:])
        let SourceImage = CIImage(cvImageBuffer: GrayBuffer)
        
        let Adjust = CIFilter.colorInvert()
        Adjust.inputImage = SourceImage
        if let Adjusted = Adjust.outputImage
        {
            var PixBuf: CVPixelBuffer? = nil
            CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, LocalBufferPool, &PixBuf)
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
}
