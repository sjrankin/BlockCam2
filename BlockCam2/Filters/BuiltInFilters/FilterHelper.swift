//
//  FilterHelper.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/25/21.
//

import Foundation
import UIKit
import CoreImage
import CoreMedia
import CoreImage.CIFilterBuiltins

class FilterHelper
{
    /// Blit the top image onto the bottom unconditionally.
    /// - Parameter Top: The top image (closest to the viewer).
    /// - Parameter Bottom: The bottom image (the background image).
    /// - Returns: Blitted image on success, nil on error.
    public static func Blit(_ Top: CIImage, _ Bottom: CIImage) -> CIImage?
    {
        let BlitFilter = CIFilter.sourceAtopCompositing()
        BlitFilter.backgroundImage = Bottom
        BlitFilter.inputImage = Top
        let Blitted = BlitFilter.outputImage
        return Blitted
    }
    
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
    
    /// Create a buffer pool with the suggested number of entries and passed format.
    /// - Parameters:
    ///   - From: Format to use for the buffer.
    ///   - BufferCountHint: Suggested number of entries in the buffer pool.
    ///   - BufferSize: If present the buffer size to create for the buffer pool. If absent, the size of
    ///                 each buffer is determined from the passed `CMFormatDescription`.
    /// - Returns: Tuple with the following contents: (The buffer pool to use, the color space of
    ///            the buffer pool, and a description of the format of the buffer pool).
    public static func CreateBufferPool(From: CMFormatDescription, BufferCountHint: Int, BufferSize: CGSize) -> CVPixelBufferPool?
    {
        let InputSubType = CMFormatDescriptionGetMediaSubType(From)
        if InputSubType != kCVPixelFormatType_32BGRA
        {
            print("Invalid pixel buffer type \(InputSubType)")
            return nil
        }
        
        let Width = Int(BufferSize.width)
        let Height = Int(BufferSize.height)
        var PixelBufferAttrs: [String: Any] =
            [
                kCVPixelBufferPixelFormatTypeKey as String: UInt(InputSubType),
                kCVPixelBufferWidthKey as String: Width,
                kCVPixelBufferHeightKey as String: Height,
                kCVPixelBufferIOSurfacePropertiesKey as String: [:]
            ]
        
        var GColorSpace = CGColorSpaceCreateDeviceRGB()
        if let FromEx = CMFormatDescriptionGetExtensions(From) as Dictionary?
        {
            let ColorPrimaries = FromEx[kCVImageBufferColorPrimariesKey]
            if let ColorPrimaries = ColorPrimaries
            {
                var ColorSpaceProps: [String: AnyObject] = [kCVImageBufferColorPrimariesKey as String: ColorPrimaries]
                if let YCbCrMatrix = FromEx[kCVImageBufferYCbCrMatrixKey]
                {
                    ColorSpaceProps[kCVImageBufferYCbCrMatrixKey as String] = YCbCrMatrix
                }
                if let XferFunc = FromEx[kCVImageBufferTransferFunctionKey]
                {
                    ColorSpaceProps[kCVImageBufferTransferFunctionKey as String] = XferFunc
                }
                PixelBufferAttrs[kCVBufferPropagatedAttachmentsKey as String] = ColorSpaceProps
            }
            if let CVColorSpace = FromEx[kCVImageBufferCGColorSpaceKey]
            {
                GColorSpace = CVColorSpace as! CGColorSpace
            }
            else
            {
                if (ColorPrimaries as? String) == (kCVImageBufferColorPrimaries_P3_D65 as String)
                {
                    GColorSpace = CGColorSpace(name: CGColorSpace.displayP3)!
                }
            }
        }
        
        let PoolAttrs = [kCVPixelBufferPoolMinimumBufferCountKey as String: BufferCountHint]
        var CVPixBufPool: CVPixelBufferPool?
        CVPixelBufferPoolCreate(kCFAllocatorDefault, PoolAttrs as NSDictionary?,
                                PixelBufferAttrs as NSDictionary?,
                                &CVPixBufPool)
        guard let BufferPool = CVPixBufPool else
        {
            print("Allocation failure - could not allocate pixel buffer pool.")
            return nil
        }
        
        PreAllocateBuffers(Pool: BufferPool, AllocationThreshold: BufferCountHint)
        
        var PixelBuffer: CVPixelBuffer?
        var OutFormatDesc: CMFormatDescription?
        let AuxAttrs = [kCVPixelBufferPoolAllocationThresholdKey as String: BufferCountHint] as NSDictionary
        CVPixelBufferPoolCreatePixelBufferWithAuxAttributes(kCFAllocatorDefault, BufferPool, AuxAttrs, &PixelBuffer)
        if let PixelBuffer = PixelBuffer
        {
            CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: PixelBuffer, formatDescriptionOut: &OutFormatDesc)
        }
        PixelBuffer = nil
        
        return BufferPool
    }
    
    /// Allocate buffers before use.
    /// - Parameters:
    ///   - Pool: The pool of pixel buffers.
    ///   - AllocationThreshold: Threshold value for allocation.
    static func PreAllocateBuffers(Pool: CVPixelBufferPool, AllocationThreshold: Int)
    {
        var PixelBuffers = [CVPixelBuffer]()
        var Error: CVReturn = kCVReturnSuccess
        let AuxAttributes = [kCVPixelBufferPoolAllocationThresholdKey as String: AllocationThreshold] as NSDictionary
        var PixelBuffer: CVPixelBuffer?
        while Error == kCVReturnSuccess
        {
            Error = CVPixelBufferPoolCreatePixelBufferWithAuxAttributes(kCFAllocatorDefault, Pool, AuxAttributes, &PixelBuffer)
            if let PixelBuffer = PixelBuffer
            {
                PixelBuffers.append(PixelBuffer)
            }
            PixelBuffer = nil
        }
        PixelBuffers.removeAll()
    }
    
    public static func GetFormatDescription(From Buffer: CVPixelBuffer) -> CMFormatDescription?
    {
        if let Desc = CMFormatDescription.make(from: Buffer)
        {
            return Desc
        }
        return nil
    }
}
