//
//  SolarizeParameters.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/16/21.
//

import Foundation
import simd

struct SolarizeParameters
{
    let SolarizeHow: simd_uint1
    let LowThreshold: simd_float1
    let HighThreshold: simd_float1
    let LowHue: simd_float1
    let HighHue: simd_float1
    let BrightnessThresholdLow: simd_float1
    let BrightnessThresholdHigh: simd_float1
    let SaturationThresholdLow: simd_float1
    let SaturationThresholdHigh: simd_float1
    let SolarizeIfGreater: simd_bool
}
