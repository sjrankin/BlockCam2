//
//  BuiltInFilterProtocol.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/21/21.
//

import Foundation

protocol BuiltInFilterProtocol
{
    static var FilterType: BuiltInFilters {get}
    static var Name: String {get}
    func RunFilter(_ Buffer: CVPixelBuffer, _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace) -> CVPixelBuffer
}
