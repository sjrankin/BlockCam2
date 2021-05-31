//
//  FilterExecution.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/28/21.
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
    // MARK: - Filter execution functions.
    
    /// Converts the passed `CVPixelBuffer` to a `UIImage`.
    /// - Parameter Buffer: The `CVPixelBuffer` to convert.
    /// - Returns: `UIImage` based on the contents of `Buffer` on success, nil on error.
    public static func BufferToUIImage(_ Buffer: CVPixelBuffer) -> UIImage?
    {
        let CImg = CIImage(cvImageBuffer: Buffer)
        let Img = UIImage(ciImage: CImg)
        return Img
    }
    
    /// Determines if all `UIImage`s passed have the same size.
    /// - Parameter For: Array of `UIImage`s.
    /// - Returns: True if all images in the passed array have the same size, false if not. False is returned
    ///            if the passed array is empty.
    public static func HomogeneousSize(For Images: [UIImage]) -> Bool
    {
        if Images.isEmpty
        {
            return false
        }
        let Width = Images[0].size.width
        let Height = Images[0].size.height
        for SomeImage in Images
        {
            if SomeImage.size.width != Width || SomeImage.size.height != Height
            {
                return false
            }
        }
        return true
    }
    
    /// Determines if all `CIImage`s passed have the same size.
    /// - Parameter For: Array of `CIImage`s.
    /// - Returns: True if all images in the passed array have the same size, false if not. False is returned
    ///            if the passed array is empty.
    public static func HomogeneousSize(For Images: [CIImage]) -> Bool
    {
        if Images.isEmpty
        {
            return false
        }
        let Width = Images[0].extent.width
        let Height = Images[0].extent.height
        for SomeImage in Images
        {
            if SomeImage.extent.width != Width || SomeImage.extent.height != Height
            {
                return false
            }
        }
        return true
    }
    
    /// Determines if all `CVPixelBuffer`s passed have the same size.
    /// - Parameter For: Array of `CVPixelBuffer`s.
    /// - Returns: True if all buffers in the passed array have the same size, false if not. False is returned
    ///            if the passed array is empty.
    public static func HomogeneousSize(In Buffers: [CVPixelBuffer]) -> Bool
    {
        if Buffers.isEmpty
        {
            return false
        }
        if let Format = FilterHelper.GetFormatDescription(From: Buffers[0])
        {
            let Width = Format.dimensions.width
            let Height = Format.dimensions.height
            for SomeBuffer in Buffers
            {
                if let BufferFormat = FilterHelper.GetFormatDescription(From: SomeBuffer)
                {
                    if BufferFormat.dimensions.width != Width || BufferFormat.dimensions.height != Height
                    {
                        return false
                    }
                }
                else
                {
                    return false
                }
            }
        }
        return true
    }
    
    /// Run a built-in filter on the passed image array.
    /// - Parameter Images: Array of `UIImage`s to process.
    /// - Parameter Filter: The filter to use. If nil, the last used filter is used. If no filter was used
    ///                     prior to this call, `.Passthrough` is used.
    /// - Returns: Filtered image according to `Filter`. Nil on error.
    public static func RunFilter(Images: [UIImage],
                                 Filter: BuiltInFilters? = nil,
                                 ReturnFirstOnError: Bool = true,
                                 _ NotUsed: Int) -> UIImage?
    {
        if Images.isEmpty
        {
            return nil
        }
        if Images.count < 2
        {
            return Images[0]
        }
        if !HomogeneousSize(For: Images)
        {
            Debug.Print("Images do not have homogeneous size.")
            return Images[0]
        }
        var Buffers = [CVPixelBuffer]()
        var Index = 0
        for SomeImage in Images
        {
            if let CImg = CIImage(image: SomeImage)
            {
                var Buffer: CVPixelBuffer?
                let Attributes = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                                  kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue,
                                  kCVPixelBufferMetalCompatibilityKey: kCFBooleanTrue] as CFDictionary
                CVPixelBufferCreate(kCFAllocatorDefault,
                                    Int(SomeImage.size.width),
                                    Int(SomeImage.size.height),
                                    kCVPixelFormatType_32BGRA,
                                    Attributes,
                                    &Buffer)
                let Context = CIContext()
                guard let ActualBuffer = Buffer else
                {
                    Debug.Print("Error creating buffer")
                    return Images[0]
                }
                Context.render(CImg, to: ActualBuffer)
                Buffers.append(ActualBuffer)
            }
            else
            {
                Debug.Print("Error converting image \(Index) to CIImage.")
                return nil
            }
            Index = Index + 1
        }
        if let Result = RunFilter(Buffers: Buffers, Filter)
        {
            let FinalImage = UIImage(Buffer: Result)
            return FinalImage
        }
        if ReturnFirstOnError
        {
            Debug.Print("Returning original image due to processing error: \(#function)")
            return Images[0]
        }
        return nil
    }
    
    /// Run a built-in filter on the passed buffer array.
    /// - Parameter Buffers: The array of buffers to filter.
    /// - Parameter Filter: The filter to use. If nil, the last used filter is used. If no filter was used
    ///                     prior to this call, `.Passthrough` is used.
    /// - Returns: Filtered data according to `Filter`. Nil on error.
    public static func RunFilter(Buffers: [CVPixelBuffer], _ Filter: BuiltInFilters? = nil) -> CVPixelBuffer?
    {
        if Filter == nil && LastBuiltInFilterUsed == nil
        {
            return Filters.RunFilter(With: Buffers[0], .Passthrough)
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
        if FilterToUse == .Passthrough
        {
            return Buffers[0]
        }
        if let FilterInTree = Filters.FilterFromTree(FilterToUse)
        {
            #if targetEnvironment(simulator)
            guard let Format = FilterHelper.GetFormatDescription(From: Buffers[0]) else
            {
                Debug.FatalError("Error getting description of buffer[0] in \(#function).")
            }
            guard let LocalBufferPool = FilterHelper.CreateBufferPool(From: Format,
                                                                      BufferCountHint: 3,
                                                                      BufferSize: CGSize(width: Int(Format.dimensions.width),
                                                                                         height: Int(Format.dimensions.height))) else
            {
                Debug.FatalError("Error creating local buffer pool in \(#function).")
            }
            FilterInTree.Initialize(With: Format, BufferCountHint: 3)
            let FinalOptions = GetOptions(For: FilterToUse)
            let FinalBuffer = FilterInTree.RunFilter(Buffers,
                                                     LocalBufferPool,
                                                     CGColorSpaceCreateDeviceRGB(),
                                                     Options: FinalOptions)
            #else
            guard let Format = FilterHelper.GetFormatDescription(From: Buffers[0]) else
            {
                Debug.FatalError("Error getting description of buffer[0] in \(#function).")
            }
            FilterInTree.Initialize(With: Format, BufferCountHint: 3)
            //            FilterInTree.Initialize(With: OutFormatDesc!, BufferCountHint: 3)
            let FinalOptions = GetOptions(For: FilterToUse)
            let FinalBuffer = FilterInTree.RunFilter(Buffers,
                                                     BufferPool!,
                                                     ColorSpace!,
                                                     Options: FinalOptions)
            #endif
            return FinalBuffer
        }
        return nil
    }
    
    /// Run a built-in filter on the passed image.
    /// - Parameter On: The image on which to run the filter.
    /// - Parameter Filter: The filter to use on the image. If this parameter is nil, the current
    ///                     filter will be used.
    /// - Parameter ReturnOriginalOnError: If true, the original image is returned on error. If false,
    ///                                    nil is returned on error.
    /// - Parameter ApplyBackground: If true, the background (as defined in `.SampleImageBackground`) is
    ///                              applied to the image before it is returned.
    /// - Returns: New and filtered `UIImage` on success, nil on error.
    public static func RunFilter(On Image: UIImage,
                                 Filter: BuiltInFilters? = nil,
                                 ReturnOriginalOnError: Bool = true,
                                 ApplyBackground: Bool = true) -> UIImage?
    {
        if let CImg = CIImage(image: Image)
        {
            var Buffer: CVPixelBuffer?
            let Attributes = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                              kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue,
                              kCVPixelBufferMetalCompatibilityKey: kCFBooleanTrue] as CFDictionary
            CVPixelBufferCreate(kCFAllocatorDefault,
                                Int(Image.size.width),
                                Int(Image.size.height),
                                kCVPixelFormatType_32BGRA,
                                Attributes,
                                &Buffer)
            let Context = CIContext()
            guard let ActualBuffer = Buffer else
            {
                Debug.Print("Error creating buffer")
                return Image
            }
            Context.render(CImg, to: ActualBuffer)
            
            if let NewBuffer = RunFilter(With: ActualBuffer, Filter)
            {
                guard let Result = UIImage(Buffer: NewBuffer) else
                {
                    return nil
                }
                if ApplyBackground
                {
                    var BGImage: UIImage!
                    switch Settings.GetInt(.SampleImageBackground)
                    {
                        case 0:
                            BGImage = UIImage.MakeColorImage(SolidColor: UIColor.black, Size: Result.size)
                            
                        case 1:
                            BGImage = UIImage.MakeColorImage(SolidColor: UIColor.white, Size: Result.size)
                            
                        case 2:
                            BGImage = MetalCheckerboard.Generate(Block: 64,
                                                                 Width: Int(Result.size.width),
                                                                 Height: Int(Result.size.height),
                                                                 Color0: UIColor.black,
                                                                 Color1: UIColor.white,
                                                                 Color2: UIColor.black,
                                                                 Color3: UIColor.white)
                        default:
                            return Result
                    }
                    
                    #if true
                    //https://stackoverflow.com/questions/1309757/blend-two-uiimages-based-on-alpha-transparency-of-top-image
                    UIGraphicsBeginImageContextWithOptions(Result.size, false, 0.0)
                    BGImage.draw(in: CGRect(origin: CGPoint.zero, size: Result.size))
                    Result.draw(in: CGRect(origin: CGPoint.zero, size: Result.size))
                    let Final = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    return Final
                    #else
                    if let Final = FilterHelper.BlitImages(Result, BGImage)
                    {
                        return Final
                    }
                    #endif
                }
                else
                {
                    return Result
                }
            }
            if ReturnOriginalOnError
            {
                Debug.Print("Returning original image due to processing error: \(#function)")
                return Image
            }
        }
        return nil
    }
    
    /// Run a built-in filter on the passed image.
    /// - Parameter On: The image (in `CIImage` format) on which to run the filter.
    /// - Parameter Extent: The size of the image.
    /// - Parameter Filter: The filter to use on the image. If this parameter is nil, the current
    ///                     filter will be used.
    /// - Parameter ReturnOriginalOnError: If true, the original image is returned on error. If false,
    ///                                    nil is returned on error.
    /// - Returns: Processed image on success, nil on error unless `ReturnOriginalOnError` is true.
    public static func RunFilter2(On Image: CIImage,
                                  Extent: CGRect,
                                  Filter: BuiltInFilters? = nil,
                                  ReturnOriginalOnError: Bool = true) -> CIImage?
    {
        var Buffer: CVPixelBuffer?
        let Attributes = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                          kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue,
                          kCVPixelBufferMetalCompatibilityKey: kCFBooleanTrue] as CFDictionary
        CVPixelBufferCreate(kCFAllocatorDefault,
                            Int(Extent.width),
                            Int(Extent.height),
                            kCVPixelFormatType_32BGRA,
                            Attributes,
                            &Buffer)
        let Context = CIContext()
        guard let ActualBuffer = Buffer else
        {
            Debug.Print("Error creating buffer")
            return Image
        }
        Context.render(Image, to: ActualBuffer)
        
        if let NewBuffer = RunFilter(With: ActualBuffer, Filter)
        {
            let FinalImage = CIImage(cvImageBuffer: NewBuffer)
            return FinalImage
        }
        if ReturnOriginalOnError
        {
            Debug.Print("Returning original image due to processing error: \(#function)")
            return Image
        }
        return nil
    }
    
    /// Run a built-in filter on the passed image.
    /// - Parameter On: The image on which to run the filter.
    /// - Parameter Filter: The filter to use on the image. If this parameter is nil, the current
    ///                     filter will be used.
    /// - Parameter ReturnOriginalOnError: If true, the original image is returned on error. If false,
    ///                                    nil is returned on error.
    /// - Parameter Block: Trailing closure that is called (if provided) after processing is complete. The
    ///                    boolean value passed to the close will be true on success, false on failure.
    /// - Returns: New and filtered `UIImage` on success, nil on error.
    public static func RunFilter(On Image: UIImage,
                                 Filter: BuiltInFilters? = nil,
                                 ReturnOriginalOnError: Bool = true,
                                 Block: ((Bool) -> ())? = nil) -> UIImage?
    {
        let Results = RunFilter(On: Image, Filter: Filter, ReturnOriginalOnError: ReturnOriginalOnError,
                                ApplyBackground: true)
        Block?(Results == nil ? false : true)
        return Results
    }
    
    /// Run a built-in filter on the passed buffer.
    /// - Parameter With: The buffer to filter.
    /// - Parameter Filter: The filter to use. If nil, the last used filter is used. If no filter was used
    ///                     prior to this call, `.Passthrough` is used.
    /// - Returns: Filtered data according to `Filter`. Nil on error.
    public static func RunFilter(With Buffer: CVPixelBuffer, _ Filter: BuiltInFilters? = nil) -> CVPixelBuffer?
    {
        if Filter == nil && LastBuiltInFilterUsed == nil
        {
            return Filters.RunFilter(With: Buffer, .Passthrough)
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
        if FilterToUse == .Passthrough
        {
            return Buffer
        }
        if let FilterInTree = Filters.FilterFromTree(FilterToUse)
        {
            #if targetEnvironment(simulator)
            guard let Format = FilterHelper.GetFormatDescription(From: Buffer) else
            {
                fatalError("Error getting description of buffer in \(#function).")
            }
            guard let LocalBufferPool = FilterHelper.CreateBufferPool(From: Format,
                                                                      BufferCountHint: 3,
                                                                      BufferSize: CGSize(width: Int(Format.dimensions.width),
                                                                                         height: Int(Format.dimensions.height))) else
            {
                fatalError("Error creating local buffer pool in \(#function).")
            }
            FilterInTree.Initialize(With: Format, BufferCountHint: 3)
            let FinalOptions = GetOptions(For: FilterToUse)
            let FinalBuffer = FilterInTree.RunFilter([Buffer],
                                                     LocalBufferPool,
                                                     CGColorSpaceCreateDeviceRGB(),
                                                     Options: FinalOptions)
            #else
            guard let Format = FilterHelper.GetFormatDescription(From: Buffer) else
            {
                fatalError("Error getting description of buffer in \(#function).")
            }
            FilterInTree.Initialize(With: Format, BufferCountHint: 3)
            //            FilterInTree.Initialize(With: OutFormatDesc!, BufferCountHint: 3)
            let FinalOptions = GetOptions(For: FilterToUse)
            let FinalBuffer = FilterInTree.RunFilter([Buffer],
                                                     BufferPool!,
                                                     ColorSpace!,
                                                     Options: FinalOptions)
            #endif
            return FinalBuffer
        }
        return nil
    }
    
    /// Run a built-in filter on the passed buffer.
    /// - Parameter With: The buffer to filter.
    /// - Parameter Filter: The filter to use. If nil, the last used filter is used. If no filter was used
    ///                     prior to this call, `.Passthrough` is used.
    /// - Returns: Filtered data according to `Filter`. Nil on error.
    public static func RunFilter(With Buffer: CVPixelBuffer, _ Filter: BuiltInFilters? = nil,
                                 Block: ((Bool) -> ())?) -> CVPixelBuffer?
    {
        let Result = RunFilter(With: Buffer, Filter)
        Block?(Result == nil ? false : true)
        return Result
    }
}
