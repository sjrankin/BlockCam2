//
//  TwirlBump.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/24/21.
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

class TwirlBump: CIFilterBase, BuiltInFilterProtocol
{
    static var FilterType: BuiltInFilters = .TwirlBump
    
    var NeedsInitialization: Bool = false
    
    func Initialize(With FormatDescription: CMFormatDescription, BufferCountHint: Int)
    {
    }
    
    func RunFilter(_ Buffer: [CVPixelBuffer], _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace, Options: [FilterOptions: Any]) -> CVPixelBuffer
    {
        let TBFilterOptions = Filters.GetOptions(For: .TwirlBump)
        var TwirlOptions = [FilterOptions: Any]()
        TwirlOptions[.Radius] = TBFilterOptions[.TwirlRadius]
        TwirlOptions[.Angle] = TBFilterOptions[.Angle]
        var BumpOptions = [FilterOptions: Any]()
        BumpOptions[.Radius] = TBFilterOptions[.BumpRadius]
        BumpOptions[.Angle] = TBFilterOptions[.Angle]
        
        let Twirled = TwirlDistortion()
        let TwirlBuffer = Twirled.RunFilter(Buffer, BufferPool, ColorSpace, Options: TwirlOptions)
        let Bumped = BumpDistortion()
        let Final = Bumped.RunFilter([TwirlBuffer], BufferPool, ColorSpace, Options: BumpOptions)
        return Final
    }
    
    /// Reset the filter's settings.
    static func ResetFilter()
    {
        Settings.SetDouble(.TwirlRadius,
                           Settings.SettingDefaults[.TwirlRadius] as! Double)
        Settings.SetDouble(.TwirlAngle,
                           Settings.SettingDefaults[.TwirlAngle] as! Double)
    }
}
