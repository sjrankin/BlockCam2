//
//  CIImage.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/14/21.
//

import Foundation
import UIKit

extension CIImage
{
    // MARK: - CIImage extensions.
    
    /// Convert the instance `CIImage` to a `UIImage`.
    /// - Returns: `UIImage` equivalent of the instance `CIImage` Nil return on error.
    func AsUIImage() -> UIImage?
    {
        let Context: CIContext = CIContext(options: nil)
        if let CGImg: CGImage = Context.createCGImage(self, from: self.extent)
        {
            let Final: UIImage = UIImage(cgImage: CGImg)
            return Final
        }
        return nil
    }
}
