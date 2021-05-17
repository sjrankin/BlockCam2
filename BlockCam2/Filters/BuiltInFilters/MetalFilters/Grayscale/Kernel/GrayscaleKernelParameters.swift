//
//  GrayscaleKernelParameters.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/15/21.
//

import Foundation
import simd

struct GrayscaleParameters
{
    let Command: simd_int1
    let RMultiplier: simd_float1
    let GMultiplier: simd_float1
    let BMultiplier: simd_float1
}
