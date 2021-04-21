//
//  UIImage.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/21/21.
//

import Foundation
import UIKit

extension UIImage
{
    // MARK: - UIImage extensions.
    
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
}
