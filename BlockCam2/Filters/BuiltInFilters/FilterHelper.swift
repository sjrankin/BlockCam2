//
//  FilterHelper.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/25/21.
//

import Foundation
import UIKit
import CoreImage

class FilterHelper
{
    /// Merge two images using the SourceAtop compositing filter.
    /// - Parameters:
    ///   - Top: The top image (eg, closest to the viewer).
    ///   - Bottom: The bottom image (eg, the background image).
    /// - Returns: Merged image on success, nil on error.
    public static func Merge(_ Top: CIImage, _ Bottom: CIImage) -> CIImage?
    {
        let InvertFilter = CIFilter(name: "CIColorInvert")
        InvertFilter?.setDefaults()
        let AlphaMaskFilter = CIFilter(name: "CIMaskToAlpha")
        AlphaMaskFilter?.setDefaults()
        let MergeSourceAtop = CIFilter(name: "CISourceAtopCompositing")
        MergeSourceAtop?.setDefaults()
        
        var FinalTop: CIImage? = nil
        InvertFilter?.setDefaults()
        AlphaMaskFilter?.setDefaults()
        
        InvertFilter?.setValue(Top, forKey: kCIInputImageKey)
        if let TopResult = InvertFilter?.value(forKey: kCIOutputImageKey) as? CIImage
        {
            AlphaMaskFilter?.setValue(TopResult, forKey: kCIInputImageKey)
            if let MaskResult = AlphaMaskFilter?.value(forKey: kCIOutputImageKey) as? CIImage
            {
                InvertFilter?.setValue(MaskResult, forKey: kCIInputImageKey)
                if let InvertedAgain = InvertFilter?.value(forKey: kCIOutputImageKey) as? CIImage
                {
                    FinalTop = InvertedAgain
                }
                else
                {
                    print("Error returned by second call to inversion filter.")
                    return nil
                }
            }
            else
            {
                print("Error returned by alpha mask filter.")
                return nil
            }
        }
        else
        {
            print("Error return by call to inversion filter.")
            return nil
        }
        
        MergeSourceAtop?.setDefaults()
        MergeSourceAtop?.setValue(FinalTop, forKey: kCIInputImageKey)
        MergeSourceAtop?.setValue(Bottom, forKey: kCIInputBackgroundImageKey)
        if let Merged = MergeSourceAtop?.value(forKey: kCIOutputImageKey) as? CIImage
        {
            return Merged
        }
        else
        {
            print("Error returned by call to image merge filter.")
            return nil
        }
    }
    
    /// Convert a `CIImage` to a `CVPixelBuffer`.
    /// - Warning: A fatal error is thrown if a buffer pool object could not be created.
    /// - Parameter Image: The image to convert.
    /// - Parameter BufferPool: The buffer pool object.
    /// - Parameter ColorSpace: Current colorspace.
    /// - Returns: `CVPixelBuffer` for the passed image.
    public static func CIImageToCVPixelBuffer(_ Image: CIImage,
                                              _ BufferPool: CVPixelBufferPool,
                                              _ ColorSpace: CGColorSpace) -> CVPixelBuffer
    {
        var PixBuf: CVPixelBuffer? = nil
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, BufferPool, &PixBuf)
        guard let OutPixBuf = PixBuf else
        {
            fatalError("Allocation failure in \(#function)")
        }
        CIContext().render(Image, to: OutPixBuf, bounds: Image.extent,
                           colorSpace: ColorSpace)
        return OutPixBuf
    }
    
    /// Converts the passed `CVPixelBuffer` to a `CIImage` (using a built-in function).
    /// - Parameter Buffer: The `CVPixelBuffer` to convert.
    /// - Returns: `CIImage` equivalent of the passed buffer.
    public static func CVPixelBufferToCIImage(_ Buffer: CVPixelBuffer) -> CIImage
    {
        return CIImage(cvPixelBuffer: Buffer)
    }
    
    public static func GradientImage(_ Frame: CGRect, IsVertical: Bool = true,
                                     Stops: [(UIColor, CGFloat)]) -> UIImage
    {
        let Layer = CAGradientLayer()
        Layer.frame = Frame
        if IsVertical
        {
            Layer.startPoint = CGPoint(x: 0.0, y: 0.0)
            Layer.endPoint = CGPoint(x: 0.0, y: 1.0)
        }
        else
        {
            Layer.startPoint = CGPoint(x: 0.0, y: 0.0)
            Layer.endPoint = CGPoint(x: 1.0, y: 0.0)
        }
        var StopData = [Any]()
        var Locations = [NSNumber]()
        for (StopColor, StopLocation) in Stops
        {
            StopData.append(StopColor.cgColor as Any)
            Locations.append(NSNumber(value: Float(StopLocation)))
        }
        Layer.colors = StopData
        Layer.locations = Locations
        
        let View = UIView()
        View.frame = Frame
        View.bounds = Frame
        View.layer.addSublayer(Layer)
        UIGraphicsBeginImageContext(View.bounds.size)
        View.layer.render(in: UIGraphicsGetCurrentContext()!)
        let Image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return Image!
    }
}
