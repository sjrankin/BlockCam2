//
//  SolarizeRGBParameters.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/17/21.
//

import Foundation
import simd

struct SolarizeRGBParameters
{
    let SolarizeHow: simd_uint1
    let Threshold: simd_float1
    let SolarizeIfGreater: simd_bool
}
