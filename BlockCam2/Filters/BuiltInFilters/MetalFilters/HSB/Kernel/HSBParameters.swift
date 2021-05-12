//
//  HSBParameters.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/6/21.
//

import Foundation
import simd

struct HSBParameters
{
    let ChangeHue: simd_bool
    let Hue: simd_float1
    let ChangeSaturation: simd_bool
    let Saturation: simd_float1
    let ChangeBrightness: simd_bool
    let Brightness: simd_float1
}
