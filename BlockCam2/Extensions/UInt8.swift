//
//  UInt8.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/31/21.
//

import Foundation
import UIKit

extension UInt8
{
    // MARK: - Size of functions.
    
    /// Returns the size of the instance UInt8.
    func SizeOf() -> Int
    {
        return MemoryLayout.size(ofValue: self)
    }
    
    /// Returns the size of UInt8.
    static func SizeOf() -> Int
    {
        return MemoryLayout.size(ofValue: UInt8(0))
    }
}
