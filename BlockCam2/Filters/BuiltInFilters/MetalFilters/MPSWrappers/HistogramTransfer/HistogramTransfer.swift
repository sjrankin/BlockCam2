//
//  HistogramTransfer.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 6/2/21.
//

import Foundation
import UIKit
import CoreMedia
import Accelerate.vImage

// Source algorithms from Apple sample code.
class HistogramTransfer: BuiltInFilterProtocol
{
    func Initialize(With FormatDescription: CMFormatDescription, BufferCountHint: Int)
    {
        //Present only for protocol purposes.
    }
    
    static var FilterType: BuiltInFilters = .HistogramTransfer
    var NeedsInitialization: Bool = true
    var AccessLock = NSObject()
    
    func RunFilter(_ PixelBuffer: [CVPixelBuffer], _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace, Options: [FilterOptions : Any]) -> CVPixelBuffer
    {
        guard let HistogramImage = Utility.GetHistogramSource() else
        {
            Debug.Print("No histogram source available.")
            return PixelBuffer.first!
        }
        
        guard let TargetImage = UIImage(Buffer: PixelBuffer[0]) else
        {
            Debug.FatalError("Error creating UIImage from buffer 0.")
        }

        guard let Processed = TransferHistogram(To: TargetImage, From: HistogramImage) else
        {
            Debug.Print("Nil returned by TransferHistogram.")
            return PixelBuffer.first!
        }
        return Processed.PixelBuffer()
    }
    
    func TransferHistogram(To Source: UIImage, From HistogramSource: UIImage) -> UIImage?
    {
        objc_sync_enter(AccessLock)
        defer{objc_sync_exit(AccessLock)}
        
        let format = vImage_CGImageFormat(bitsPerComponent: 8,
                                          bitsPerPixel: 32,
                                          colorSpace: CGColorSpaceCreateDeviceRGB(),
                                          bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue),
                                          renderingIntent: .defaultIntent)!
        
        // Source image
        guard
            let sourceCGImage = Source.cgImage,
            var sourceBuffer = try? vImage_Buffer(cgImage: sourceCGImage,
                                                  format: format) else
        {
            return nil
        }
        
        defer {
            sourceBuffer.free()
        }
        
        // Histogram source / Reference image
        guard
            let histogramSourceCGImage = HistogramSource.cgImage,
            var histogramSourceBuffer = try? vImage_Buffer(cgImage: histogramSourceCGImage,
                                                           format: format) else
        {
            return nil
        }
        
        defer {
            histogramSourceBuffer.free()
        }
        
        var histogramBinZero = [vImagePixelCount](repeating: 0, count: 256)
        var histogramBinOne = [vImagePixelCount](repeating: 0, count: 256)
        var histogramBinTwo = [vImagePixelCount](repeating: 0, count: 256)
        var histogramBinThree = [vImagePixelCount](repeating: 0, count: 256)
        
        histogramBinZero.withUnsafeMutableBufferPointer
        {
            zeroPtr in
            histogramBinOne.withUnsafeMutableBufferPointer
            {
                onePtr in
                histogramBinTwo.withUnsafeMutableBufferPointer
                {
                    twoPtr in
                    histogramBinThree.withUnsafeMutableBufferPointer
                    {
                        threePtr in
                        var histogramBins = [zeroPtr.baseAddress, onePtr.baseAddress,
                                             twoPtr.baseAddress, threePtr.baseAddress]
                        
                        histogramBins.withUnsafeMutableBufferPointer
                        {
                            histogramBinsPtr in
                            let error = vImageHistogramCalculation_ARGB8888(&histogramSourceBuffer,
                                                                            histogramBinsPtr.baseAddress!,
                                                                            vImage_Flags(kvImageNoFlags))
                            
                            guard error == kvImageNoError else
                            {
                                Debug.FatalError("Error calculating histogram: \(error)")
                            }
                        }
                    }
                }
            }
        }
        
        histogramBinZero.withUnsafeBufferPointer
        {
            zeroPtr in
            histogramBinOne.withUnsafeBufferPointer
            {
                onePtr in
                histogramBinTwo.withUnsafeBufferPointer
                {
                    twoPtr in
                    histogramBinThree.withUnsafeBufferPointer
                    {
                        threePtr in
                        var histogramBins = [zeroPtr.baseAddress, onePtr.baseAddress,
                                             twoPtr.baseAddress, threePtr.baseAddress]
                        
                        histogramBins.withUnsafeMutableBufferPointer
                        {
                            histogramBinsPtr in
                            let error = vImageHistogramSpecification_ARGB8888(&sourceBuffer,
                                                                              &sourceBuffer,
                                                                              histogramBinsPtr.baseAddress!,
                                                                              vImage_Flags(kvImageLeaveAlphaUnchanged))
                            
                            guard error == kvImageNoError else
                            {
                                Debug.FatalError("Error specifying histogram: \(error)")
                            }
                        }
                    }
                }
            }
        }
        
        if let cgImage = try? sourceBuffer.createCGImage(format: format)
        {
            return UIImage(cgImage: cgImage)
        }
        else
        {
            return nil
        }
    }
    
    /// Reset the filter's settings.
    static func ResetFilter()
    {
    }
}
