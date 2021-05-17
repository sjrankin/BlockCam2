//
//  ChannelSwizzleParameters.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/16/21.
//

import Foundation
import simd

struct ChannelSwizzles
{
    //Values: 0 = r, 1 = g, 2 = b, 3 = h, 4 = s, 5 = L, 6 = c, 7 = m, 8 = y, 9 = k
    let Channel1: simd_int1
    let Channel2: simd_int1
    let Channel3: simd_int1
    let HasHSB: simd_bool
    let HasCMYK: simd_bool
    let InvertRed: simd_bool
    let InvertGreen: simd_bool
    let InvertBlue: simd_bool
}
