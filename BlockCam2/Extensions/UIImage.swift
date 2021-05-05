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
    
    /// Create a UI image from a pixel buffer.
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
}
