//
//  ConditionalTransparencyParameters.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/28/21.
//

import Foundation
import simd

struct ConditionalTransparencyParameters
{
    let BrightnessThreshold: simd_float1
    let InvertThreshold: simd_bool
}
