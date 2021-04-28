//
//  ThresholdParameters.swift
//  BlockCam2
//  Adapted from BumpCamera, 2/7/19.
//
//  Created by Stuart Rankin on 4/26/21.
//

import Foundation
import simd

struct ThresholdParameters
{
    let ThresholdValue: simd_float1
    let ThresholdInput: simd_uint1
    let ApplyIfHigher: simd_bool
    let LowColor: simd_float4
    let HighColor: simd_float4
}
