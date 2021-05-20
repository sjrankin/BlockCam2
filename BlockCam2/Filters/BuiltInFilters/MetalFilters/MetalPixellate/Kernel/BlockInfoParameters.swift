//
//  BlockInfoParameters.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/19/21.
//

import Foundation
import simd

struct BlockInfoParameters
{
    let Width: simd_uint1
    let Height: simd_uint1
    let HighlightAction: simd_uint1
    let HighlightPixelBy: simd_uint1
    let BrightnessHighlight: simd_uint1
    let HighlightColor: simd_float4
    let ColorDetermination: simd_uint1
    let HighlightValue: simd_float1
    let HighlightIfGreater: simd_bool
    let AddBorder: simd_bool
    let BorderColor: simd_float4
}
