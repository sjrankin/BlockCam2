//
//  MirroringParameters.swift
//  BlockCam2
//  Adapted from BumpCamera, 2/2/19.
//
//  Created by Stuart Rankin on 4/26/21.
//

import Foundation
import simd

struct MirrorParameters
{
    //0 = horizontal (left to right), 1 = vertical (top to bottom), 2 = quadrant,
    //3 = mirror horizontally, 4 = mirror vertically
    let Direction: simd_uint1
    //0 = left, 1 = right
    let HorizontalSide: simd_uint1
    //0 = top, 1 = bottom
    let VerticalSide: simd_uint1
    //quadrant to reflect
    let Quadrant: simd_uint1
    //set to true if image source is AV foundation
    let IsAVRotated: simd_bool
}
