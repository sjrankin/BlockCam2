//
//  SimpleInversionParameters.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 6/1/21.
//

import Foundation
import simd

struct SimpleInversionParameters
{
    let Channel: simd_uint1
}

enum InversionChannels: Int
{
    case Red = 0
    case Green = 1
    case Blue = 2
    case Hue = 3
    case Saturation = 4
    case Brightness = 5
    case Cyan = 6
    case Magenta = 7
    case Yellow = 8
    case Black = 9
}
