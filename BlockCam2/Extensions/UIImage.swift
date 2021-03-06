//
//  UIImage.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/21/21.
//

import Foundation
import UIKit
import VideoToolbox

extension UIImage
{
    // MARK: - UIImage extensions.
    
    /// Create a `UIImage` from a pixel buffer.
    /// - Note: See [How to turn a CVPixelBuffer Into a UIImage](https://stackoverflow.com/questions/8072208/how-to-turn-a-cvpixelbuffer-into-a-uiimage)
    /// - Parameter Buffer: A `CVPixelBuffer` with image data to convert to a `UIImage`.
    /// - Returns: `UIImage` on success, nil on failure.
    public convenience init?(Buffer: CVPixelBuffer)
    {
        var CGImg: CGImage? = nil
        VTCreateCGImageFromCVPixelBuffer(Buffer, options: nil, imageOut: &CGImg)
        guard let FinalCG = CGImg else
        {
            return nil
        }
        self.init(cgImage: FinalCG)
    }
    
    /// Create a `UIImage` from the contents of the file in the passed URL.
    /// - Parameter FromURL: The URL that describes where the file is.
    /// - Returns: `UIImage` on success, nil on failure.
    public convenience init?(FileURL: URL)
    {
        guard let SomeImage = UIImage(contentsOfFile: FileURL.path) else
        {
            return nil
        }
        guard let JpgData = SomeImage.jpegData(compressionQuality: 1.0) else
        {
            return nil
        }
        self.init(data: JpgData)
    }
    
    /// Create a `UIImage` from a HEIC file.
    /// - Parameter HEIC: URL to the .heic file to convert.
    /// - Returns: `UIImage` on success, nil on failure.
    public convenience init?(HEIC: URL)
    {
        guard let HeicImage = UIImage(contentsOfFile: HEIC.path) else
        {
            return nil
        }
        guard let JpgData = HeicImage.jpegData(compressionQuality: 1.0) else
        {
            return nil
        }
        self.init(data: JpgData)
    }
    
    /// Rotate the instance image by the passed number of radians.
    /// - Parameter By: Number of radians by which to rotate the image.
    /// - Returns: New image rotated the indicated number of radians.
    func RotateImage(By Radians: Double) -> UIImage
    {
        var NewSize = CGRect(origin: CGPoint.zero, size: self.size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(Radians))).size
        NewSize.width = floor(NewSize.width)
        NewSize.height = floor(NewSize.height)
        UIGraphicsBeginImageContextWithOptions(NewSize, false, self.scale)
        let Context = UIGraphicsGetCurrentContext()!
        Context.translateBy(x: NewSize.width / 2, y: NewSize.height / 2)
        Context.rotate(by: CGFloat(Radians))
        self.draw(in: CGRect(x: -self.size.width / 2,
                             y: -self.size.height / 2,
                             width: self.size.width,
                             height: self.size.height))
        let NewImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return NewImage!
    }
    
    /// Returns an image with a solid color and passed size.
    /// - Parameters:
    ///   - SolidColor: The color to fill the image with.
    ///   - Size: The size of the image.
    /// - Returns: UIImage filled with the specified color on success, nil on error.
    public static func MakeColorImage(SolidColor: UIColor, Size: CGSize) -> UIImage?
    {
        let Rect = CGRect(x: 0, y: 0, width: Size.width, height: Size.height)
        
        let FinalColor = CIColor(red: SolidColor.r, green: SolidColor.g, blue: SolidColor.b, alpha: SolidColor.a)
        var ciImage = CIImage(color: FinalColor)
        ciImage = ciImage.cropped(to: Rect)
        let ciContext = CIContext()
        if let cgImg = ciContext.createCGImage(ciImage, from: ciImage.extent)
        {
            let uiImg = UIImage(cgImage: cgImg)
            return uiImg
        }
        else
        {
            fatalError("Error backing image with CG.")
        }
    }
    
    //https://stackoverflow.com/questions/44462087/how-to-convert-a-uiimage-to-a-cvpixelbuffer
    public func PixelBuffer() -> CVPixelBuffer
    {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferMetalCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(self.size.width),
                                         Int(self.size.height),
                                         kCVPixelFormatType_32ARGB,
                                         attrs,
                                         &pixelBuffer)
        guard status == kCVReturnSuccess else
        {
            Debug.FatalError("Error \(status) returned by CVPixelBufferCreate")
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData,
                                width: Int(self.size.width),
                                height: Int(self.size.height),
                                bitsPerComponent: 8,
                                bytesPerRow:
                                    CVPixelBufferGetBytesPerRow(pixelBuffer!),
                                space: rgbColorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer!
    }
}
