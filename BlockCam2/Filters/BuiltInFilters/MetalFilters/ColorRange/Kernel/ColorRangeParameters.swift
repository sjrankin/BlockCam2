//
//  ColorRangeParameters.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/29/21.
//

import Foundation
import simd

struct ColorRangeParameters
{
    let RangeStart: simd_float1
    let RangeEnd: simd_float1
    let InvertRange: simd_bool
    let NonRangeAction: simd_uint1
    let NonRangeColor: simd_float4
}

enum NonRangeActions: Int
{
    case GrayscaleMean = 0
    case GrayscaleGreatest = 1
    case GrayscaleSmallest = 2
    case InvertHue = 3
    case InvertBrightness = 4
    case ReduceBrightness = 5
    case ReduceSaturation = 6
    case UseNonRangeColor = 7
}
