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
class SampleImageData
{
    init(id: String, SampleName: String, Title: String, Attribution: String, IsUserImage: Bool)
    {
        self.id = id
        self.SampleName = SampleName
        self.Title = Title
        self.Attribution = Attribution
        self.IsUserImage = IsUserImage
        
        if IsUserImage
        {
            let ActualURL = SampleImages.URLForSample(Name: SampleName)
            SampleImage = FileIO.LoadImage(ActualURL)
        }
        else
        {
            SampleImage = UIImage(named: SampleName)
        }
    }
    
    /// ID of the sample image.
    var id: String = ""
    /// Name of the sample image in the asset catalog.
    var SampleName: String = ""
    /// Human-readable title for the sample.
    var Title: String = ""
    /// Attribution of the image.
    var Attribution: String = ""
    /// Flag that indicates the image is from the user.
    var IsUserImage: Bool = false
    var SampleImage: UIImage? = nil
    
    func AsStruct() -> SampleImageDataStruct
    {
        return SampleImageDataStruct(id: self.id,
                                     SampleName: self.SampleName,
                                     Title: self.Title,
                                     Attribution: self.Attribution,
                                     IsUserImage: self.IsUserImage,
                                     SampleImage: self.SampleImage)
    }
}

struct SampleImageDataStruct: Equatable, Hashable
{
    var id: String = ""
    /// Name of the sample image in the asset catalog.
    var SampleName: String = ""
    /// Human-readable title for the sample.
    var Title: String = ""
    /// Attribution of the image.
    var Attribution: String = ""
    /// Flag that indicates the image is from the user.
    var IsUserImage: Bool = false
    var SampleImage: UIImage? = nil
}

/// Manages sample images.
class SampleImages
{
    /// Initialize the sample image manager.
    public static func Initialize()
    {
        MaxSamples = BuiltInSamples.count
        InitializeUserSamples()
    }
    
    public static var SampleSource: SampleSources
    {
        get
        {
            if Settings.GetBool(.UseLatestBlockCamImage)
            {
                return SampleSources.LastBlockCam
            }
            if Settings.GetBool(.UseMostRecentImage)
            {
                return SampleSources.MostRecent
            }
            return SampleSources.BuiltIn
        }
    }
    
    /// Contains all built-in sample images.
    /// - Note: Sample images will be shown in the order defined here.
    public static var BuiltInSamples: [SampleImageData] =
    [
        SampleImageData(id: "Sample1", SampleName: "SampleImage1", Title: "Black Cat",
                        Attribution: "Author", IsUserImage: false),
        SampleImageData(id: "Sample12", SampleName: "SampleImage12", Title: "Norio the Cat",
                        Attribution: "Author", IsUserImage: false),
        SampleImageData(id: "Sample20", SampleName: "SampleImage20", Title: "Great Wave Off Kanagawa",
                        Attribution: "Katsushika Hokusai, Rijksmuseum", IsUserImage: false),
        SampleImageData(id: "Sample4", SampleName: "SampleImage4", Title: "Lantern Spook Yōkai",
                        Attribution: "Katsushika Hokusai, Rijksmuseum", IsUserImage: false),
        SampleImageData(id: "Sample16", SampleName: "SampleImage16", Title: "Woman in Blue Combing Her Hair",
                        Attribution: "Goyo Hashiguchi, National Diet Library", IsUserImage: false),
        SampleImageData(id: "Sample19", SampleName: "SampleImage19", Title: "Grotesque Mask",
                        Attribution: "Cornelis Floris, Rijksmuseum", IsUserImage: false),
        SampleImageData(id: "Sample24", SampleName: "SampleImage24", Title: "Rhinoceros",
                        Attribution: "Albrecht Dürer, Rijksmuseum", IsUserImage: false),
        SampleImageData(id: "Sample2", SampleName: "SampleImage2", Title: "The Jolly Flatboatmen",
                        Attribution: "George Caleb Bingham, National Gallery of Art", IsUserImage: false),
        SampleImageData(id: "Sample3", SampleName: "SampleImage3", Title: "Cherry Blossoms",
                        Attribution: "Photo by AJ on Unsplash", IsUserImage: false),
        SampleImageData(id: "Sample9", SampleName: "SampleImage9", Title: "France and Western Europe",
                        Attribution: "NASA Terra MODIS", IsUserImage: false),

        SampleImageData(id: "Sample28", SampleName: "SampleImage28", Title: "Apollo 17 Orbiting the Moon",
                        Attribution: "NASA/Apollo 17", IsUserImage: false),
        SampleImageData(id: "Sample29", SampleName: "SampleImage29", Title: "MSL Gale Crater",
                        Attribution: "NASA/JPL/Mars Curiosity Rover", IsUserImage: false),
        SampleImageData(id: "Sample15", SampleName: "SampleImage15", Title: "San Francisco Bay Area",
                        Attribution: "NASA Landsat 7", IsUserImage: false),
        SampleImageData(id: "Sample17", SampleName: "SampleImage17", Title: "Galaxy NGC 4921",
                        Attribution: "NASA/ESA Hubble Space Telescope", IsUserImage: false),
        SampleImageData(id: "Sample10", SampleName: "SampleImage10", Title: "Orion Nebula, M42",
                        Attribution: "NASA/ESA Hubble Space Telescope", IsUserImage: false),
        SampleImageData(id: "Sample21", SampleName: "SampleImage21", Title: "Grid with Red Lines",
                        Attribution: "Author", IsUserImage: false),
        /*
        
        SampleImageData(id: "Sample5", SampleName: "SampleImage5", Title: "New York City",
                        Attribution: "Photo by Sean Driscoll on Unsplash", IsUserImage: false),
        SampleImageData(id: "Sample6", SampleName: "SampleImage6", Title: "Flowing Purple Liquid",
                        Attribution: "Photo by Solen Feyissa on Unsplash", IsUserImage: false),
        SampleImageData(id: "Sample7", SampleName: "SampleImage7", Title: "Black and White Moon",
                        Attribution: "Photo by Alexander Andrews on Unsplash", IsUserImage: false),
        SampleImageData(id: "Sample8", SampleName: "SampleImage8", Title: "Rose",
                        Attribution: "Photo by Annie Spratt on Unsplash", IsUserImage: false),

        SampleImageData(id: "Sample11", SampleName: "SampleImage11", Title: "ACO S 295",
                        Attribution: "NASA/ESA Hubble Space Telescope", IsUserImage: false),
        SampleImageData(id: "Sample13", SampleName: "SampleImage13", Title: "Lights in Japan",
                        Attribution: "Photo by Luca Florio on Unsplash", IsUserImage: false),
        SampleImageData(id: "Sample14", SampleName: "SampleImage14", Title: "Posing Lady",
                        Attribution: "Photo by Muhammadtaha Ibrahim Ma'aji on Unsplash", IsUserImage: false),
        SampleImageData(id: "Sample18", SampleName: "SampleImage18", Title: "Izu Mountains",
                        Attribution: "Photo by Peter Nguyen on Unsplash", IsUserImage: false),
        SampleImageData(id: "Sample22", SampleName: "SampleImage22", Title: "The Zojo Shrine in Shiba",
                        Attribution: "Kawase Hasui, Rijksmuseum", IsUserImage: false),
        SampleImageData(id: "Sample23", SampleName: "SampleImage23", Title: "Melancholia I",
                        Attribution: "Albrecht Dürer, Rijksmuseum", IsUserImage: false),
        SampleImageData(id: "Sample24", SampleName: "SampleImage24", Title: "Rhinoceros",
                        Attribution: "Albrecht Dürer, Rijksmuseum", IsUserImage: false),
        SampleImageData(id: "Sample25", SampleName: "SampleImage25", Title: "The Tyger",
                        Attribution: "William Blake, British Museum", IsUserImage: false),
        SampleImageData(id: "Sample26", SampleName: "SampleImage26", Title: "Europe a Prophecy",
                        Attribution: "William Blake, British Museum", IsUserImage: false),
        SampleImageData(id: "Sample27", SampleName: "SampleImage27", Title: "Yōkai Figure",
                        Attribution: "Author", IsUserImage: false),
        SampleImageData(id: "Sample29", SampleName: "SampleImage29", Title: "MSL Gale Crater",
                        Attribution: "NASA/JPL/Mars Curiosity Rover", IsUserImage: false)
 */
    ]
    
    /// Current number of sample images.
    public static var MaxSamples: Int = 0
    
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
    
    // MARK: - Manage user-defined sample images
    
    /// Holds an arry of user-defined sample image data.
    public static var UserDefinedSamples = [SampleImageData]()
    
    /// Save the user sample list to settings.
    /// - Note: This is called whenever a function that manipulates the list is called and probably should
    ///         not be called otherwise.
    public static func SaveUserSampleList()
    {
        var Result = ""
        for UserData in UserDefinedSamples
        {
            Result.append(UserData.SampleName)
            Result.append("")
            Result.append(UserData.Title)
            Result.append("")
        }
        Settings.SetString(.UserSampleList, Result)
        print("Saved: \(Result)")
    }
    
    /// Initialized user samples.
    /// - Note:
    ///  - Reads the user sample list from settings.
    ///  - Removes any unattached files in the user sample directory.
    public static func InitializeUserSamples()
    {
        if let Raw = Settings.GetString(.UserSampleList)
        {
            if !Raw.isEmpty
            {
                let Parts = Raw.split(separator: "", omittingEmptySubsequences: true)
                if !Parts.count.isMultiple(of: 2)
                {
                    Debug.Print("String at .\(SettingKeys.UserSampleList.rawValue) is corrupt - uneven number of entries.")
                    Settings.SetString(.UserSampleList, "")
                    return
                }
                var Index = 0
                while Index < Parts.count
                {
                    let FileName = String(Parts[Index])
                    Index = Index + 1
                    let Description = String(Parts[Index])
                    Index = Index + 1
                    let ImageData = SampleImageData(id: FileName,
                                                    SampleName: FileName,
                                                    Title: Description,
                                                    Attribution: "User Image",
                                                    IsUserImage: true)
                    UserDefinedSamples.append(ImageData)
                }
                let DirURL = FileIO.GetDirectoryURL(DirectoryName: FileIO.SampleDirectory)
                let Contents = FileIO.GetFilesIn(Directory: DirURL!)
                if UserDefinedSamples.count > Contents!.count
                {
                    //We're in an unstable state. Clear the contents and list.
                    Debug.Print("Mismatch between user sample list and user samples - in unstable state. Clearing user sample list and directory.")
                    UserDefinedSamples.removeAll()
                    FileIO.ClearDirectory(FileIO.SampleDirectory)
                    return
                }
                RemoveUnattachedImages()
            }
            else
            {
                print("User sample list is empty (inner)")
            }
        }
        else
        {
            print("User sample list is empty (outer)")
        }
    }
    
    /// Determines if the passed file name exists in the current user sample list.
    /// - Parameter FileName: The file name to look for in the user sample list.
    /// - Returns: True if the file name was found, false if not.
    public static func FileInUserList(_ FileName: String) -> Bool
    {
        for UserImage in UserDefinedSamples
        {
            print("--> \(UserImage.SampleName)")
            if UserImage.SampleName == FileName
            {
                return true
            }
        }
        return false
    }
    
    /// Add a new user sample to the user sample list.
    /// - Note:
    ///    - If the callers sets `OverWrite` to `false` and `false` is returned, the image alreadys exists.
    ///      In that case, the caller is expected to query the user and if the user agrees, make a
    ///      call again with `OverWrite` set to `true`.
    /// - Parameter FileName: The name of the file of the user sample image. Also used as the sample
    ///                       name.
    /// - Parameter Description: The user's description for the sample image.
    /// - Parameter Image: Image to save.
    /// - Parameter OverWrite: If `true`, if a file with the same name already exists, it will be
    ///                        overwritten. If `false`, when a file with the same name is encountered,
    ///                        `false` will be returned.
    /// - Returns: `True` on success, `false` if the file already exists.
    public static func AddUserSample(FileName: String,
                                     Description: String,
                                     Image: UIImage,
                                     OverWrite: Bool = false) -> Bool
    {
        if !OverWrite
        {
            if FileInUserList(FileName)
            {
                return false
            }
        }
        var FileURL = FileIO.GetDirectoryURL(DirectoryName: FileIO.SampleDirectory)
        FileURL?.appendPathComponent(FileName)
        if FileIO.FileExists(FileURL!)
        {
            FileIO.DeleteFile(FileURL!)
        }
        guard FileIO.SaveImage(Image, WithName: FileName, Directory: FileIO.SampleDirectory) else
        {
            return false
        }
        let ImageData = SampleImageData(id: FileName,
                                        SampleName: FileName,
                                        Title: Description,
                                        Attribution: "User Image",
                                        IsUserImage: true)
        UserDefinedSamples.append(ImageData)
        SaveUserSampleList()
        return true
    }
    
    /// Returns the index of the sample image whose name is `FileName`.
    /// - Note: The index is based on the **current** `UserDefinedSamples` array. For that reason the
    ///         returned value should be used immediately. There is no guarentee that the value will be
    ///         valid after making other function calls into this class.
    /// - Parameter FileName: The name of the file whose index will be returned. See Notes.
    /// - Returns: Index of the user sample image data for the given file name. Returns `-1` if not found.
    public static func IndexOfUserSample(_ FileName: String) -> Int
    {
        if let Index = UserDefinedSamples.firstIndex(where: {$0.SampleName == FileName})
        {
            return Index
        }
        return -1
    }
    
    /// Update the description of a user sample image.
    /// - Parameter FileName: Determines which description to update.
    /// - Parameter Description: The new description.
    public static func EditUserSample(FileName: String,
                                      Description: String)
    {
        let SampleIndex = IndexOfUserSample(FileName)
        if SampleIndex < 0
        {
            Debug.Print("Did not find sample with name \(FileName)")
            return
        }
        UserDefinedSamples[SampleIndex].Title = Description
        SaveUserSampleList()
    }
    
    /// Determines if the specified user sample exists in the user sample list.
    /// - Parameter SampleName: The name of the user sample (assumed to be a file name) to check
    ///             for existence in the user sample list.
    /// - Returns: True if the sample file name was found, false if not.
    public static func UserSampleExists(_ SampleName: String) -> Bool
    {
        for UserData in UserDefinedSamples
        {
            if UserData.SampleName == SampleName
            {
                return true
            }
        }
        return false
    }
    
    /// Delete the specified user sample.
    /// - Note: The sample image will be delted from BlockCam's user sample directory and the entry in the
    ///         user sample list will be removed.
    /// - Parameter With: The sample image name (expected to be a file name) to delete. If it does not exist,
    ///                   no action is taken.
    public static func DeleteUserSample(With SampleName: String)
    {
        if !UserSampleExists(SampleName)
        {
            Debug.Print("Did not delete \(SampleName) - entry not found.")
            return
        }
        for UserData in UserDefinedSamples
        {
            if UserData.SampleName == SampleName
            {
                var FileURL = FileIO.GetDirectoryURL(DirectoryName: FileIO.SampleDirectory)
                FileURL?.appendPathComponent(UserData.SampleName)
                FileIO.DeleteFile(FileURL!)
                break
            }
        }
        UserDefinedSamples = UserDefinedSamples.filter({$0.SampleName != SampleName})
        SaveUserSampleList()
    }
    
    /// Delete all user samples.
    /// - Note: All sample images in BlockCam's user sample directory will be deleted (but not the original
    ///         images) and the user defined sample list will be cleared.
    public static func DeleteAllUserSamples()
    {
        for UserData in UserDefinedSamples
        {
            var FileURL = FileIO.GetDirectoryURL(DirectoryName: FileIO.SampleDirectory)
            FileURL?.appendPathComponent(UserData.SampleName)
            FileIO.DeleteFile(FileURL!)
        }
        UserDefinedSamples.removeAll()
        SaveUserSampleList()
    }
    
    /// Remove all unattached images in the user sample directory.
    /// - Note:
    ///   - "Unattached" images are images whose names are not referenced in the user sample list.
    ///   - The user sample directory is created here if it does not exist.
    public static func RemoveUnattachedImages()
    {
        FileIO.CreateIfDoesNotExist(DirectoryName: FileIO.SampleDirectory)
        guard let FilesInSampleDirectory = FileIO.GetFilesIn(Directory: FileIO.GetDirectoryURL(DirectoryName: FileIO.SampleDirectory)!) else
        {
            Debug.Print("Error returned getting files in \(FileIO.SampleDirectory)")
            return
        }
        if FilesInSampleDirectory.isEmpty
        {
            return
        }
        var FileNameSet = Set<String>()
        for FileURL in FilesInSampleDirectory
        {
            let FileName = FileURL.lastPathComponent
            FileNameSet.insert(FileName)
        }
        var ListNameSet = Set<String>()
        for UserSample in UserDefinedSamples
        {
            ListNameSet.insert(UserSample.SampleName)
        }
        let Union = ListNameSet.union(FileNameSet)
        let Unattached = FileNameSet.subtracting(Union)
        let SampleDirectory = FileIO.GetDirectoryURL(DirectoryName: FileIO.SampleDirectory)
        for SomeImage in Unattached
        {
            Debug.Print("Removing unattached file \(SomeImage)")
            if let FileURL = SampleDirectory?.appendingPathComponent(SomeImage)
            {
                FileIO.DeleteFile(FileURL)
            }
        }
    }
    
    /// Return the URL for the user sample image whose name is passed.
    /// - Warning: Will throw a fatal error if the URL cannot be determined.
    /// - Parameter Name: Name of the user sample image.
    /// - Returns: URL for the specified user sample image.
    static func URLForSample(Name: String) -> URL
    {
        var BaseURL = FileIO.GetDirectoryURL(DirectoryName: FileIO.SampleDirectory)
        BaseURL = BaseURL?.appendingPathComponent(Name)
        guard BaseURL != nil else
        {
            Debug.FatalError("Error creating URL for \(Name)")
        }
        return BaseURL!
    }
    
    static func GetUserDataStruct() -> [SampleImageDataStruct]
    {
        var Results = [SampleImageDataStruct]()
        for UserItem in UserDefinedSamples
        {
            Results.append(UserItem.AsStruct())
        }
        return Results
    }
}

enum SampleSources: String, CaseIterable
{
    case BuiltIn = "Built-In"
    case User = "User"
    case LastBlockCam = "Last BlockCam Image"
    case MostRecent = "Most Recent Image"
}
