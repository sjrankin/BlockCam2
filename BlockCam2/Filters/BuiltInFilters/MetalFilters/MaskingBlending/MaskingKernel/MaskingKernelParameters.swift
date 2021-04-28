//
//  MaskingKernelParameters.swift
//  BlockCam2
//  Adapted from BumpCamera, 3/13/19.
//
//  Created by Stuart Rankin on 4/26/21.
//

import Foundation
import simd

struct MaskingKernelParameters
{
    let MaskColor: simd_float4
    let Tolerance: simd_int1
}
