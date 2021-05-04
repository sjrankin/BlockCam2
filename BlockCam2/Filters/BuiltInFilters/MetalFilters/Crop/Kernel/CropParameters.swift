//
//  CropParameters.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/2/21.
//

import Foundation
import simd

struct CropParameters
{
    let StartX: simd_int1
    let StartY: simd_int1
    let Width: simd_int1
    let Height: simd_int1
}
