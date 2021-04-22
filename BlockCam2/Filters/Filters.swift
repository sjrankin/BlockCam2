//
//  Filters.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/18/21.
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

class Filters
{
    public static func InitializeFilters()
    {
        InitializeBuiltInFilters()
    }
    
    public static func Initialize(From: CMFormatDescription, Caller: String)
    {
        let InputSubType = CMFormatDescriptionGetMediaSubType(From)
        if InputSubType != kCVPixelFormatType_32BGRA
        {
            fatalError("Invalid pixel buffer type \(InputSubType)")
        }
        
        let InputSize = CMVideoFormatDescriptionGetDimensions(From)
        var PixelBufferAttrs: [String: Any] =
            [
                kCVPixelBufferPixelFormatTypeKey as String: UInt(InputSubType),
                kCVPixelBufferWidthKey as String: Int(InputSize.width),
                kCVPixelBufferHeightKey as String: Int(InputSize.height),
                kCVPixelBufferIOSurfacePropertiesKey as String: [:]
            ]
        
        var GColorSpace = CGColorSpaceCreateDeviceRGB()
        if let FromEx = CMFormatDescriptionGetExtensions(From) as Dictionary?
        {
            let ColorPrimaries = FromEx[kCVImageBufferColorPrimariesKey]
            if let ColorPrimaries = ColorPrimaries
            {
                var ColorSpaceProps: [String: AnyObject] = [kCVImageBufferColorPrimariesKey as String: ColorPrimaries]
                if let YCbCrMatrix = FromEx[kCVImageBufferYCbCrMatrixKey]
                {
                    ColorSpaceProps[kCVImageBufferYCbCrMatrixKey as String] = YCbCrMatrix
                }
                if let XferFunc = FromEx[kCVImageBufferTransferFunctionKey]
                {
                    ColorSpaceProps[kCVImageBufferTransferFunctionKey as String] = XferFunc
                }
                PixelBufferAttrs[kCVBufferPropagatedAttachmentsKey as String] = ColorSpaceProps
            }
            if let CVColorSpace = FromEx[kCVImageBufferCGColorSpaceKey]
            {
                GColorSpace = CVColorSpace as! CGColorSpace
            }
            else
            {
                if (ColorPrimaries as? String) == (kCVImageBufferColorPrimaries_P3_D65 as String)
                {
                    GColorSpace = CGColorSpace(name: CGColorSpace.displayP3)!
                }
            }
        }
        ColorSpace = GColorSpace
        
        let PoolAttrs = [kCVPixelBufferPoolMinimumBufferCountKey as String: 3]
        var CVPixBufPool: CVPixelBufferPool?
        CVPixelBufferPoolCreate(kCFAllocatorDefault, PoolAttrs as NSDictionary?,
                                PixelBufferAttrs as NSDictionary?,
                                &CVPixBufPool)
        guard let WorkingBufferPool = CVPixBufPool else
        {
            fatalError("Allocation failure - could not allocate pixel buffer pool.")
        }
        
        PreAllocateBuffers(Pool: WorkingBufferPool, AllocationThreshold: 3)
        
        var PixelBuffer: CVPixelBuffer?
        var OutFormatDesc: CMFormatDescription?
        let AuxAttrs = [kCVPixelBufferPoolAllocationThresholdKey as String: 3] as NSDictionary
        CVPixelBufferPoolCreatePixelBufferWithAuxAttributes(kCFAllocatorDefault, WorkingBufferPool, AuxAttrs, &PixelBuffer)
        if let PixelBuffer = PixelBuffer
        {
            CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: PixelBuffer, formatDescriptionOut: &OutFormatDesc)
        }
        PixelBuffer = nil
        BufferPool = WorkingBufferPool
    }
    
    private static var ColorSpace: CGColorSpace? = nil
    private static var Context: CIContext? = nil
    
    /// Allocate buffers before use.
    ///
    /// - Parameters:
    ///   - Pool: The pool of pixel buffers.
    ///   - AllocationThreshold: Threshold value for allocation.
    static func PreAllocateBuffers(Pool: CVPixelBufferPool, AllocationThreshold: Int)
    {
        var PixelBuffers = [CVPixelBuffer]()
        var Error: CVReturn = kCVReturnSuccess
        let AuxAttributes = [kCVPixelBufferPoolAllocationThresholdKey as String: AllocationThreshold] as NSDictionary
        var PixelBuffer: CVPixelBuffer?
        while Error == kCVReturnSuccess
        {
            Error = CVPixelBufferPoolCreatePixelBufferWithAuxAttributes(kCFAllocatorDefault, Pool, AuxAttributes, &PixelBuffer)
            if let PixelBuffer = PixelBuffer
            {
                PixelBuffers.append(PixelBuffer)
            }
            PixelBuffer = nil
        }
        PixelBuffers.removeAll()
    }
    
    static var BufferPool: CVPixelBufferPool? = nil
    
    /// Run a built-in filter on the passed buffer.
    /// - Parameter Filter: The filter to use. If nil, the last used filter is used. If no filter was used
    ///                     prior to this call, `.Passthrough` is used.
    /// - Parameter With: The buffer to filter.
    /// - Returns: Filtered data according to `Filter`. Nil on error.
    public static func RunFilter(_ Filter: BuiltInFilters? = nil,
                                 With Buffer: CVPixelBuffer) -> CVPixelBuffer?
    {
        if Filter == nil && LastBuiltInFilterUsed == nil
        {
            return Filters.RunFilter(.Passthrough, With: Buffer)
        }
        var FilterToUse: BuiltInFilters = .Passthrough
        if Filter == nil
        {
            FilterToUse = LastBuiltInFilterUsed!
        }
        else
        {
            LastBuiltInFilterUsed = Filter
            FilterToUse = Filter!
        }
        if let SomeFilter = BuiltInFilterMap[FilterToUse]
        {
            return SomeFilter.RunFilter(Buffer, BufferPool!, ColorSpace!)
        }
        return nil
    }
    
    public static func SetFilter(_ NewFilter: BuiltInFilters)
    {
        LastBuiltInFilterUsed = NewFilter
    }
    
    static var LastBuiltInFilterUsed: BuiltInFilters? = nil
}

enum BuiltInFilters: String, CaseIterable
{
    case Passthrough = "No Filter"
    case LineOverlay = "Line Overlay"
    case Pixellate = "Pixellate"
    case FalseColor = "False Color"
    case HueAdjust = "Hue Adjust"
    case ExposureAdjust = "Exposure Adjust"
    case Posterize = "Posterize"
    case Noir = "Noir"
    case LinearTosRGB = "Linear to sRGB"
    case Chrome = "Chrome"
    case Sepia = "Sepia"
    case DotScreen = "Dot Screen"
    case LineScreen = "Line Screen"
    case CircularScreen = "Circular Screen"
    case HatchedScreen = "Hatched Screen"
    case CMYKHalftone = "CMYK Halftone"
    case Instant = "Instant Effect"
    case Fade = "Fade Effect"
    case Mono = "Mono Effect"
    case Process = "Process Effect"
    case Tonal = "Tonal Effect"
    case Transfer = "Transfer Effect"
    case Vibrance = "Vibrance Effect"
    case XRay = "X-Ray"
    case Comic = "Comic Effect"
    case TriangleKaleidoscope = "Triangle Kaleidoscope"
    case Kaleidoscope = "Kaleidoscope"
    case ColorMonochrome = "Color Monochrome"
    case MaximumComponent = "Component, Maximum"
    case MinimumComponent = "Component, Minimum"
    case HistogramDisplay = "Histogram Display"
}
