//
//  SampleImages.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/19/21.
//

import Foundation
import UIKit
import CoreLocation
import Photos
import SwiftUI

/// Contains data on one built-in sample image.
struct SampleImageData
{
    /// ID of the sample image.
    var id: String
    /// Name of the sample image in the asset catalog.
    var SampleName: String
    /// Human-readable title for the sample.
    var Title: String
    /// Attribution of the image.
    var Attribution: String
}

/// Manages sample images.
class SampleImages
{
    /// Initialize the sample image manager.
    public static func Initialize()
    {
        MaxSamples = BuiltInSamples.count
    }
    
    /// Contains all built-in sample images.
    /// - Note: Sample images will be shown in the order defined here.
    public static var BuiltInSamples: [SampleImageData] =
    [
        SampleImageData(id: "Sample1", SampleName: "SampleImage1", Title: "Black Cat",
                        Attribution: "Author"),
        SampleImageData(id: "Sample12", SampleName: "SampleImage12", Title: "Norio the Cat",
                        Attribution: "Author"),
        SampleImageData(id: "Sample20", SampleName: "SampleImage20", Title: "Great Wave Off Kanagawa",
                        Attribution: "Katsushika Hokusai, Rijksmuseum"),
        SampleImageData(id: "Sample4", SampleName: "SampleImage4", Title: "Lantern Spook Yōkai",
                        Attribution: "Katsushika Hokusai, Rijksmuseum"),
        SampleImageData(id: "Sample16", SampleName: "SampleImage16", Title: "Woman in Blue Combing Her Hair",
                        Attribution: "Goyo Hashiguchi, National Diet Library"),
        SampleImageData(id: "Sample19", SampleName: "SampleImage19", Title: "Grotesque Mask",
                        Attribution: "Cornelis Floris, Rijksmuseum"),
        SampleImageData(id: "Sample24", SampleName: "SampleImage24", Title: "Rhinoceros",
                        Attribution: "Albrecht Dürer, Rijksmuseum"),
        SampleImageData(id: "Sample2", SampleName: "SampleImage2", Title: "The Jolly Flatboatmen",
                        Attribution: "George Caleb Bingham, National Gallery of Art"),
        SampleImageData(id: "Sample3", SampleName: "SampleImage3", Title: "Cherry Blossoms",
                        Attribution: "Photo by AJ on Unsplash"),
        SampleImageData(id: "Sample9", SampleName: "SampleImage9", Title: "France and Western Europe",
                        Attribution: "NASA Terra MODIS"),

        SampleImageData(id: "Sample28", SampleName: "SampleImage28", Title: "Apollo 17 Orbiting the Moon",
                        Attribution: "NASA/Apollo 17"),
        SampleImageData(id: "Sample29", SampleName: "SampleImage29", Title: "MSL Gale Crater",
                        Attribution: "NASA/JPL/Mars Curiosity Rover"),
        SampleImageData(id: "Sample15", SampleName: "SampleImage15", Title: "San Francisco Bay Area",
                        Attribution: "NASA Landsat 7"),
        SampleImageData(id: "Sample17", SampleName: "SampleImage17", Title: "Galaxy NGC 4921",
                        Attribution: "NASA/ESA Hubble Space Telescope"),
        SampleImageData(id: "Sample10", SampleName: "SampleImage10", Title: "Orion Nebula, M42",
                        Attribution: "NASA/ESA Hubble Space Telescope"),
        SampleImageData(id: "Sample21", SampleName: "SampleImage21", Title: "Grid with Red Lines",
                        Attribution: "Author"),
        /*
        
        SampleImageData(id: "Sample5", SampleName: "SampleImage5", Title: "New York City",
                        Attribution: "Photo by Sean Driscoll on Unsplash"),
        SampleImageData(id: "Sample6", SampleName: "SampleImage6", Title: "Flowing Purple Liquid",
                        Attribution: "Photo by Solen Feyissa on Unsplash"),
        SampleImageData(id: "Sample7", SampleName: "SampleImage7", Title: "Black and White Moon",
                        Attribution: "Photo by Alexander Andrews on Unsplash"),
        SampleImageData(id: "Sample8", SampleName: "SampleImage8", Title: "Rose",
                        Attribution: "Photo by Annie Spratt on Unsplash"),

        SampleImageData(id: "Sample11", SampleName: "SampleImage11", Title: "ACO S 295",
                        Attribution: "NASA/ESA Hubble Space Telescope"),
        SampleImageData(id: "Sample13", SampleName: "SampleImage13", Title: "Lights in Japan",
                        Attribution: "Photo by Luca Florio on Unsplash"),
        SampleImageData(id: "Sample14", SampleName: "SampleImage14", Title: "Posing Lady",
                        Attribution: "Photo by Muhammadtaha Ibrahim Ma'aji on Unsplash"),
        SampleImageData(id: "Sample18", SampleName: "SampleImage18", Title: "Izu Mountains",
                        Attribution: "Photo by Peter Nguyen on Unsplash"),
        SampleImageData(id: "Sample22", SampleName: "SampleImage22", Title: "The Zojo Shrine in Shiba",
                        Attribution: "Kawase Hasui, Rijksmuseum"),
        SampleImageData(id: "Sample23", SampleName: "SampleImage23", Title: "Melancholia I",
                        Attribution: "Albrecht Dürer, Rijksmuseum"),
        SampleImageData(id: "Sample24", SampleName: "SampleImage24", Title: "Rhinoceros",
                        Attribution: "Albrecht Dürer, Rijksmuseum"),
        SampleImageData(id: "Sample25", SampleName: "SampleImage25", Title: "The Tyger",
                        Attribution: "William Blake, British Museum"),
        SampleImageData(id: "Sample26", SampleName: "SampleImage26", Title: "Europe a Prophecy",
                        Attribution: "William Blake, British Museum"),
        SampleImageData(id: "Sample27", SampleName: "SampleImage27", Title: "Yōkai Figure",
                        Attribution: "Author"),
        SampleImageData(id: "Sample29", SampleName: "SampleImage29", Title: "MSL Gale Crater",
                        Attribution: "NASA/JPL/Mars Curiosity Rover")
 */
    ]
    
    /// Current number of sample images.
    public static var MaxSamples: Int = 0
    /*
    public static let BuiltInSamples =
        [
            "Sample1" : "Cat",
            "Sample2" : "Mom",
            "Sample3" : "Yōkai",
            "Sample4" : "Galaxy",
            "Sample5" : "Hokkaido",
            "Sample6" : "Apollo 17",
            "Sample7" : "MSL Gale Crater",
            "Sample8" : "Grid"
        ]
 */
    
    /// Returns a nice sample name for the current sample image.
    /// - Returns: Nice sample name for the current sample image. If the sample
    ///            image has a name not understood, a default name is returned.
    public static func GetCurrentSampleImageName() -> String
    {
        for SampleData in BuiltInSamples
        {
            if SampleData.SampleName == GetSampleImageName()
            {
                return SampleData.Title
            }
        }
        /*
        if let Name = BuiltInSamples[GetSampleImageName()]
        {
            return Name
        }
 */
        return "Sample Image"
    }
    
    public static func GetCurrentSampleIndex() -> Int
    {
        var Index = 0
        let CurrentName = GetSampleImageName()
        for SampleData in BuiltInSamples
        {
            if SampleData.SampleName == CurrentName
            {
                return Index
            }
            Index = Index + 1
        }
        return 0
    }
    
    public static var CurrentSample: SampleImageData
    {
        get
        {
            
            return BuiltInSamples[GetCurrentSampleIndex()]
        }
    }
    
    /// Returns a nice sample name for the sample image title passed.
    /// - Parameter From: The name of the sample image whose nice title is returned.
    /// - Returns: Nice sample name for the current sample image. If the passed sample
    ///            name is not understood, a default name is returned.
    public static func GetCurrentSampleImageName(From Title: String) -> String
    {
        for SampleData in BuiltInSamples
        {
            if SampleData.SampleName == Title
            {
                return SampleData.Title
            }
        }
        /*
        if let Name = BuiltInSamples[Title]
        {
            return Name
        }
 */
        return "SampleImage"
    }
    
    public static func ValidatedIndex(_ Index: Int) -> Int
    {
        if Index < 0
        {
            return 0
        }
        if Index > BuiltInSamples.count - 1
        {
            return BuiltInSamples.count - 1
        }
        return Index
    }
    
    /// Returns the current sample image. Current is defined by the value
    /// `.SampleImageIndex` in the settings system.
    /// - Returns: Current sample image.
    public static func GetCurrentSampleImage() -> UIImage
    {
        if Settings.GetBool(.UseLatestBlockCamImage)
        {
            if let LastImage = FileIO.GetLastBlockCamImage()
            {
                return LastImage
            }
        }
        if Settings.GetBool(.UseMostRecentImage)
        {
            if let MostRecent = RecentImage
            {
                return MostRecent
            }
        }
        var Index = Settings.GetInt(.SampleImageIndex)
        if Index < 0
        {
            Index = 0
            Settings.SetInt(.SampleImageIndex, Index)
        }
        return UIImage(named: BuiltInSamples[Index].SampleName)!
        /*
        let Name = "SampleImage\(Index)"
        if let Result = UIImage(named: Name)
        {
            return Result
        }
        else
        {
            return UIImage(named: "SampleImage1")!
        }
 */
    }
    
    /// Increments the sample image and returns the new image.
    /// - Returns: Next image in a positive direction. Wraps around to the
    ///            first image automatically.
    public static func IncrementSampleImage() -> UIImage
    {
        var Index = Settings.GetInt(.SampleImageIndex)
        if Index < 0
        {
            Index = BuiltInSamples.count - 1
            Settings.SetInt(.SampleImageIndex, Index)
        }
        Index = Index + 1
        if Index > BuiltInSamples.count - 1
        {
            Index = 0
            Settings.SetInt(.SampleImageIndex, Index)
        }
        print("IncrementSampleImage: Index=\(Index)")
        Settings.SetInt(.SampleImageIndex, Index)
        return GetCurrentSampleImage()
    }
    
    /// Increments the sample image name and returns the new name.
    /// - Returns: Next name in a positive direction. Wraps around to the
    ///            first name automatically.
    public static func IncrementSampleImageName() -> String
    {
        var Index = Settings.GetInt(.SampleImageIndex)
        if Index < 0
        {
            Index = BuiltInSamples.count - 1
            Settings.SetInt(.SampleImageIndex, Index)
        }
        Index = Index + 1
        if Index > BuiltInSamples.count - 1
        {
            Index = 0
            Settings.SetInt(.SampleImageIndex, Index)
        }
        Settings.SetInt(.SampleImageIndex, Index)
        return GetSampleImageName()
    }
    
    /// Decrements the sample image and returns the new image.
    /// - Returns: Next image in a negative direction. Wraps around to the
    ///            last image automatically.
    public static func DecrementSampleImage() -> UIImage
    {
        var Index = Settings.GetInt(.SampleImageIndex)
        if Index < 0
        {
            Index = 0
            Settings.SetInt(.SampleImageIndex, Index)
        }
        Index = Index - 1
        if Index < 0
        {
            Index = MaxSamples - 1
        }
        Settings.SetInt(.SampleImageIndex, Index)
        return GetCurrentSampleImage()
    }
    
    /// Decrements the sample image and returns the new name.
    /// - Returns: Next name in a negative direction. Wraps around to the
    ///            last name automatically.
    public static func DecrementSampleImageName() -> String
    {
        var Index = Settings.GetInt(.SampleImageIndex)
        if Index < 0
        {
            Index = 0
            Settings.SetInt(.SampleImageIndex, Index)
        }
        Index = Index - 1
        if Index < 0
        {
            Index = MaxSamples - 1
            Settings.SetInt(.SampleImageIndex, Index)
        }
        Settings.SetInt(.SampleImageIndex, Index)
        return GetSampleImageName()
    }
    
    /// Returns the current sample image name (stored in the asset catalog).
    /// - Returns: Current sample image name.
    public static func GetSampleImageName() -> String
    {
        var Index = Settings.GetInt(.SampleImageIndex)
        if Index < 0
        {
            Index = 0
            Settings.SetInt(.SampleImageIndex, Index)
        }
        if Index >= BuiltInSamples.count
        {
            Index = BuiltInSamples.count - 1
            Settings.SetInt(.SampleImageIndex, Index)
        }
        return BuiltInSamples[Index].SampleName
//        return "SampleIndex\(Index)"
    }
    
    /// Resets the sample image to the first in the asset catalog.
    /// - Returns: First sample image.
    public static func ResetSampleImage() -> UIImage
    {
        Settings.SetInt(.SampleImageIndex, 1)
        return GetCurrentSampleImage()
    }
    
    /// Resets the sample image name to the first image in the sample image asset catalog.
    /// - Returns: First sample image name.
    public static func ResetSampleImageName() -> String
    {
        Settings.SetInt(.SampleImageIndex, 1)
        return GetSampleImageName()
    }
    
    /// Holds the most recent image from the user's photo album at start-up
    /// of the program.
    public static var RecentImage: UIImage? = nil
    
    /// Retrieve the most recent image from the photo album.
    /// - Note:
    ///    - See [How to retrieve the most recent photo from the camera roll](https://stackoverflow.com/questions/10200553/how-to-retrieve-the-most-recent-photo-from-camera-roll-on-ios)
    ///    - On success, the image is saved in `SampleImages.RecentImage`.
    ///    - This function should be called early in the initialization process to help ensure it is available
    ///      if the user choses to use this feature.
    public static func GetRecentAlbumImage()
    {
        let Options = PHFetchOptions()
        Options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let Request = PHImageRequestOptions()
        Request.isSynchronous = true
        let Result = PHAsset.fetchAssets(with: .image, options: Options)
        if let Asset = Result.firstObject
        {
            let Manager = PHImageManager.default()
            let Size = CGSize(width: Asset.pixelWidth, height: Asset.pixelHeight)
            Manager.requestImage(for: Asset,
                                 targetSize: Size,
                                 contentMode: .aspectFit,
                                 options: Request)
            {
                Image, Info in
                RecentImage = Image
            }
        }
    }
}
