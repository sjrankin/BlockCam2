//
//  ArithmeticConstantParameters.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 6/4/21.
//

import Foundation
import simd

struct ArithmeticConstantParameters
{
    let NormalClamp: simd_bool
    let r: simd_float1
    let g: simd_float1
    let b: simd_float1
    let a: simd_float1
    let UseRed: simd_bool
    let UseGreen: simd_bool
    let UseBlue: simd_bool
    let UseAlpha: simd_bool
}
