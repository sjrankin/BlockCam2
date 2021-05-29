//
//  ImageDeltaParameters.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/28/21.
//

import Foundation
import simd

struct ImageDeltaParameters
{
    let BackgroundColor: simd_float4
    let Operation: simd_uint1
    let Threshold: simd_float1
    let UseEffectiveColor: simd_bool
    let EffectiveColor: simd_float4
}
