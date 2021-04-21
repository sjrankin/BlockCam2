//
//  BuiltIn.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/21/21.
//

import Foundation
import UIKit
import SceneKit
import AVFoundation
import CoreImage
import CoreServices
import AVKit
import Photos
import MobileCoreServices
import CoreMotion
import CoreMedia
import CoreVideo
import CoreImage.CIFilterBuiltins

extension Filters
{
    public static func InitializeBuiltInFilters()
    {
        BuiltInFilterMap[.Chrome] = BlockCam2.Chrome()
        BuiltInFilterMap[.CircularScreen] = BlockCam2.CircularScreen()
        BuiltInFilterMap[.CMYKHalftone] = BlockCam2.CMYKHalftone()
        BuiltInFilterMap[.Comic] = BlockCam2.Comic()
        BuiltInFilterMap[.DotScreen] = BlockCam2.DotScreen()
        BuiltInFilterMap[.ExposureAdjust] = BlockCam2.ExposureAdjust()
        BuiltInFilterMap[.Fade] = BlockCam2.Fade()
        BuiltInFilterMap[.FalseColor] = BlockCam2.FalseColor()
        BuiltInFilterMap[.HatchedScreen] = BlockCam2.HatchedScreen()
        BuiltInFilterMap[.HueAdjust] = BlockCam2.HueAdjust()
        BuiltInFilterMap[.Instant] = BlockCam2.Instant()
        BuiltInFilterMap[.LinearTosRGB] = BlockCam2.LinearTosRGB()
        BuiltInFilterMap[.LineOverlay] = BlockCam2.LineOverlay()
        BuiltInFilterMap[.LineScreen] = BlockCam2.LineScreen()
        BuiltInFilterMap[.Mono] = BlockCam2.Mono() 
        BuiltInFilterMap[.Noir] = BlockCam2.Noir()
        BuiltInFilterMap[.Passthrough] = BlockCam2.Passthrough()
        BuiltInFilterMap[.Pixellate] = BlockCam2.Pixellate()
        BuiltInFilterMap[.Posterize] = BlockCam2.Posterize()
        BuiltInFilterMap[.Process] = BlockCam2.Process()
        BuiltInFilterMap[.Sepia] = BlockCam2.Sepia()
        BuiltInFilterMap[.Tonal] = BlockCam2.Tonal()
        BuiltInFilterMap[.Transfer] = BlockCam2.Transfer()
        BuiltInFilterMap[.Vibrance] = BlockCam2.Vibrance()
        BuiltInFilterMap[.XRay] = BlockCam2.XRay()
    }
    
    public static var BuiltInFilterMap = [BuiltInFilters: BuiltInFilterProtocol]()
    
    public static func AlphabetizedFilterNames() -> [String]
    {
        let NameArray = BuiltInFilterMap.keys.map({$0.rawValue}).sorted()
        return NameArray
    }
}
