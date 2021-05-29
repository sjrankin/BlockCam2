//
//  MultiFrameParameters.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/27/21.
//

import Foundation
import simd

struct MultiFrameParameters
{
    let InvertComparison: simd_bool
    let Comparison: simd_uint1
}

enum MultiFrameComparisons: Int
{
    case BrightestPixel = 0
    case BrightestRed = 1
    case BrightestGreen = 2
    case BrightestBlue = 3
    case BrightestCyan = 4
    case BrightestMagenta = 5
    case BrightestYellow = 6
}
