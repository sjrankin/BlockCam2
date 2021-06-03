//
//  FileIO.swift
//  BlockCam2
//  Adapted from BumpCam.
//
//  Created by Stuart Rankin on 4/20/21.
//

import Foundation
import UIKit

/// Class that handles saving and retrieving files in the documents directory.
class FileIO
{
    /// Name of the directory where user sample images (for viewing filter settings) are stored.
    static let SampleDirectory = "/UserSamples"
    
    /// Name of the directory where the user's source image for histogram transfer resides.
    static let HistogramSourceDirectory = "/HistogramSource"
    
    /// Name of the directory that holds the last image taken by BlockCam.
    static let LastImageDirectory = "/LastImage"
    
    /// Name of the directory where scratch images are saved (for the purposes of appending meta data before
    /// being moved to the photo roll).
    static let ScratchDirectory = "/Scratch"
    
    /// Name of the directory where performance data is exported.
    static let PerformanceDirectory = "/Performance"
    
    /// Name of the directory used at runtime.
    static let RuntimeDirectory = "/Runtime"
    
    /// Name of the directory used for debugging.
    static let DebugDirectory = "/Debug"
    
    /// Determines if the passed directory exists. If it does not, it is created.
    /// - Note: A false return indicates something is terribly wrong and execution should stop.
    /// - Parameter DirectoryName: The name of the directory to test for existence. This name will be used
    ///                            to create the directory if it does not exist.
    /// - Returns: True on success (the directory already existed or was created successfully), false on error (the
    ///            directory does not exist and could not be created). A false return value indicates a fatal error
    ///            and execution should stop as soon as posible.
    public static func CreateIfDoesNotExist(DirectoryName: String) -> Bool
    {
        if DirectoryExists(DirectoryName: DirectoryName)
        {
            Debug.Print("\(DirectoryName) exists.")
            return true
        }
        else
        {
            let DirURL = CreateDirectory(DirectoryName: DirectoryName)
            if DirURL == nil
            {
                Debug.FatalError("Error creating \(DirectoryName)")
            }
        }
        Debug.Print("\(DirectoryName) created.")
        return true
    }
    
    /// Returns an URL for the document directory.
    ///
    /// - Returns: Document directory URL on success, nil on error.
    public static func GetDocumentDirectory() -> URL?
    {
        let Dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return Dir
    }
    
    /// Determines if the passed directory exists. The document directory is used as the root directory (eg,
    /// the directory name is appended to the document directory).
    ///
    /// - Parameter DirectoryName: The directory to check for existence. The name of the directory is searched
    ///                            from the document directory.
    /// - Returns: True if the directory exists, false if not.
    public static func DirectoryExists(DirectoryName: String) -> Bool
    {
        let CPath = GetDocumentDirectory()?.appendingPathComponent(DirectoryName)
        if CPath == nil
        {
            return false
        }
        return FileManager.default.fileExists(atPath: CPath!.path)
    }
    
    /// Simple wrapper around the `fileExists` function.
    public static func FileExists(_ FileURL: URL) -> Bool
    {
        return FileManager.default.fileExists(atPath: FileURL.path)
    }
    
    /// Create a directory in the document directory.
    ///
    /// - Parameter DirectoryName: Name of the directory to create.
    /// - Returns: URL of the newly created directory on success, nil on error.
    @discardableResult public static func CreateDirectory(DirectoryName: String) -> URL?
    {
        var CPath: URL!
        do
        {
            CPath = GetDocumentDirectory()?.appendingPathComponent(DirectoryName)
            try FileManager.default.createDirectory(atPath: CPath!.path, withIntermediateDirectories: true, attributes: nil)
        }
        catch
        {
            Debug.FatalError("Error creating directory \(CPath.path): \(error.localizedDescription)")
        }
        return CPath
    }
    
    /// Returns the URL of the passed directory. The directory is assumed to be a sub-directory of the
    /// document directory.
    ///
    /// - Parameter DirectoryName: Name of the directory whose URL is returned.
    /// - Returns: URL of the directory on success, nil if not found.
    public static func GetDirectoryURL(DirectoryName: String) -> URL?
    {
        if !DirectoryExists(DirectoryName: DirectoryName)
        {
            return nil
        }
        let CPath = GetDocumentDirectory()?.appendingPathComponent(DirectoryName)
        return CPath
    }
    
    /// Return an URL to the scratch directory.
    ///
    /// - Returns: URL of the directory on success, nil if not found.
    public static func ScratchDirectoryURL() -> URL?
    {
        return GetDirectoryURL(DirectoryName: ScratchDirectory)
    }
    
    /// Remove all files from the given directory.
    ///
    /// - Note: [Delete files from directory](https://stackoverflow.com/questions/32840190/delete-files-from-directory-inside-document-directory)
    ///
    /// - Parameter Name: Name of the directory whose contents will be deleted.
    /// - Returns: True on success, false on failure.
    @discardableResult public static func ClearDirectory(_ Name: String) -> Bool
    {
        if !DirectoryExists(DirectoryName: Name)
        {
            Debug.Print("Directory \(Name) does not exist.")
            return false
        }
        let CPath = GetDocumentDirectory()?.appendingPathComponent(Name)
        do
        {
            let Contents = try FileManager.default.contentsOfDirectory(atPath: CPath!.path)
            for Content in Contents
            {
                let ContentPath = CPath?.appendingPathComponent(Content)
                do
                {
                    try FileManager.default.removeItem(at: ContentPath!)
                }
                catch
                {
                    Debug.Print("Error removing \((ContentPath?.path)!): \(error.localizedDescription)")
                    return false
                }
            }
        }
        catch
        {
            Debug.Print("Error getting contents of \(CPath!.path): \(error.localizedDescription)")
            return false
        }
        return true
    }
    
    /// Return a list of all files (in URL form) in the passed directory.
    ///
    /// - Parameters:
    ///   - Directory: URL of the directory whose contents will be returned.
    ///   - FilterBy: How to filter the results. This is assumed to be a list of file extensions.
    /// - Returns: List of files in the specified directory.
    public static func GetFilesIn(Directory: URL, FilterBy: String? = nil) -> [URL]?
    {
        var URLs: [URL]!
        do
        {
            URLs = try FileManager.default.contentsOfDirectory(at: Directory, includingPropertiesForKeys: nil)
        }
        catch
        {
            return nil
        }
        if FilterBy != nil
        {
            let Scratch = URLs.filter{$0.pathExtension == FilterBy!}
            URLs.removeAll()
            for SomeURL in Scratch
            {
                URLs.append(SomeURL)
            }
        }
        return URLs
    }
    
    /// Return an image from the passed URL.
    ///
    /// - Parameter From: URL of the image (including all directory parts).
    /// - Returns: UIImage form of the image at the passed URL. Nil on error or file not found.
    public static func LoadImage(_ From: URL) -> UIImage?
    {
        if InMaximumPrivacy()
        {
            print("In Maximum Privacy mode. No reading of directories allowed.")
            return nil
        }
        do
        {
            let ImageData = try Data(contentsOf: From)
            let Final = UIImage(data: ImageData)
            return Final
        }
        catch
        {
            Debug.Print("Error loading image at \(From.path): \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Returns an image from the last BlockCam image directory.
    /// - Parameter FileName: Name of the image file to return. Defaults to `LastBlockCamImage.jpg`.
    /// - Returns: The image on success, nil if not found or on error.
    public static func GetLastBlockCamImage(FileName: String = "LastBlockCamImage.jpg") -> UIImage?
    {
        if let CPath = GetDocumentDirectory()?.appendingPathComponent(LastImageDirectory)
        {
            do
            {
                let FinalName = CPath.appendingPathComponent(FileName)
                let ImageData = try Data(contentsOf: FinalName)
                let Image = UIImage(data: ImageData)
                return Image
            }
            catch
            {
                Debug.Print("Error loading image data for LastBlockCamImage.jpg")
                return nil
            }
        }
        return nil
    }
    
    /// Returns an image from the historgram source image directory.
    /// - Parameter FileName: Name of the image file to return. Defaults to `HistogramSource.jpg`.
    /// - Returns: The image on success, nil if not found or on error.
    public static func GetHistogramSourceImage(FileName: String = "HistogramSource.jpg") -> UIImage?
    {
        if let CPath = GetDocumentDirectory()?.appendingPathComponent(HistogramSourceDirectory)
        {
            do
            {
                let FinalName = CPath.appendingPathComponent(FileName)
                let ImageData = try Data(contentsOf: FinalName)
                let Image = UIImage(data: ImageData)
                return Image
            }
            catch
            {
                Debug.Print("Error loading image data for HistogramSource.jpg")
                return nil
            }
        }
        return nil
    }
    
    /// Returns the sample user images and file names.
    /// - Returns: Array of tuples of user sample images and file names.
    public static func GetUserSampleImages() -> [(Name: String, Image: UIImage)]?
    {
        if !DirectoryExists(DirectoryName: SampleDirectory)
        {
            CreateDirectory(DirectoryName: SampleDirectory)
        }
        if let SampleURL = GetDirectoryURL(DirectoryName: SampleDirectory)
        {
            if let Images = GetFilesIn(Directory: SampleURL)
            {
                var Results = [(Name: String, Image: UIImage)]()
                for SomeFile in Images
                {
                    if let SomeImage = LoadImage(SomeFile)
                    {
                        let SomeName = SomeFile.lastPathComponent
                        Results.append((Name: SomeName, Image: SomeImage))
                    }
                }
                return Results
            }
        }
        return nil
    }
    
    /// Save an image to the specified directory.
    /// - Parameters:
    ///   - Image: The UIImage to save.
    ///   - WithName: The name to use when saving the image.
    ///   - InDirectory: The directory in which to save the image.
    ///   - AsJPG: If true, save as a .JPG image. If false, save as a .PNG image.
    /// - Returns: True on success, false on failure.
    public static func SaveImage(_ Image: UIImage, WithName: String, InDirectory: URL,
                                 AsJPG: Bool = true) -> Bool
    {
        if InMaximumPrivacy()
        {
            print("In Maximum Privacy mode. No image writing allowed.")
            return false
        }
        if AsJPG
        {
            if let Data = Image.jpegData(compressionQuality: 1.0)
            {
                let FileName = InDirectory.appendingPathComponent(WithName)
                do
                {
                    try Data.write(to: FileName)
                }
                catch
                {
                    Debug.Print("Error writing \(FileName.path): \(error.localizedDescription)")
                    return false
                }
            }
        }
        else
        {
            if let Data = Image.pngData()
            {
                let FileName = InDirectory.appendingPathComponent(WithName)
                do
                {
                    try Data.write(to: FileName)
                }
                catch
                {
                    Debug.Print("Error writing \(FileName.path): \(error.localizedDescription)")
                    return false
                }
            }
        }
        return true
    }
    
    /// Save an image to the specified directory.
    /// - Parameters:
    ///   - Image: The UIImage to save.
    ///   - WithName: The name to use when saving the image.
    ///   - Directory: Name of the directory where to save the image.
    ///   - AsJPG: If true, save as a .JPG image. If false, save as a .PNG image.
    /// - Returns: True on success, nil on failure.
    @discardableResult public static func SaveImage(_ Image: UIImage, WithName: String, Directory: String,
                                                    AsJPG: Bool = true) -> Bool
    {
        if !DirectoryExists(DirectoryName: Directory)
        {
            CreateDirectory(DirectoryName: Directory)
        }
        let FinalDirectory = GetDirectoryURL(DirectoryName: Directory)
        return SaveImage(Image, WithName: WithName, InDirectory: FinalDirectory!, AsJPG: AsJPG)
    }
    
    /// Save an image the user has selected as a sample image for filter settings.
    ///
    /// - Parameter SampleImage: The sample image in UIImage format.
    /// - Returns: True on success, false on failure.
    public static func SaveSampleImage(_ SampleImage: UIImage) -> Bool
    {
        return SaveImage(SampleImage, WithName: "UserSelected.jpg", Directory: SampleDirectory, AsJPG: true)
    }
    
    /// Save an image to the scratch directory.
    ///
    /// - Parameters:
    ///   - ScratchImage: The image to save to the scratch directory.
    ///   - WithName: The name to use when saving the image.
    /// - Returns: True on success, false on failure.
    public static func SaveScratchImage(_ ScratchImage: UIImage, WithName: String) -> Bool
    {
        return SaveImage(ScratchImage, WithName: WithName, Directory: ScratchDirectory, AsJPG: true)
    }
    
    /// Return the user-selected sample image previously stored in the sample image directory.
    ///
    /// - Returns: The sample image as a UIImage on success, nil if not found or on failure.
    public static func GetSampleImage() -> UIImage?
    {
        if InMaximumPrivacy()
        {
            print("In Maximum Privacy mode. No sample images allowed.")
            return nil
        }
        if !DirectoryExists(DirectoryName: SampleDirectory)
        {
            CreateDirectory(DirectoryName: SampleDirectory)
        }
        if let SampleURL = GetDirectoryURL(DirectoryName: SampleDirectory)
        {
            if let Images = GetFilesIn(Directory: SampleURL)
            {
                if Images.count < 1
                {
                    Debug.Print("No files returned from " + SampleDirectory)
                    return nil
                }
                return LoadImage(Images[0])
            }
            else
            {
                Debug.Print("No images found in " + SampleDirectory)
                return nil
            }
        }
        else
        {
            Debug.Print("Error getting URL for " + SampleDirectory)
            return nil
        }
    }
    
    /// Return the name of the user-selected sample image previously stored in the sample image directory.
    ///
    /// - Returns: The name of the sample image on success, nil on failure.
    public static func GetSampleImageName() -> String?
    {
        if InMaximumPrivacy()
        {
            print("In Maximum Privacy mode. No sample images allowed.")
            return nil
        }
        if !DirectoryExists(DirectoryName: SampleDirectory)
        {
            return nil
        }
        if let SampleURL = GetDirectoryURL(DirectoryName: SampleDirectory)
        {
            if let Images = GetFilesIn(Directory: SampleURL)
            {
                if Images.count < 1
                {
                    Debug.Print("No files returned.")
                    return nil
                }
                return Images[0].path
            }
            else
            {
                Debug.Print("No files found in " + SampleDirectory)
                return nil
            }
        }
        else
        {
            Debug.Print("Error getting URL for " + SampleDirectory)
            return nil
        }
    }
    
    /// Delete the file at the specified URL.
    ///
    /// - Parameter FileURL: The URL of the file to delete.
    /// - Returns: True if the file was deleted, false if not.
    public static func DeleteFile(_ FileURL: URL) -> Bool
    {
        if !FileManager.default.fileExists(atPath: FileURL.path)
        {
            Debug.Print("Unable to find the file \(FileURL.path) - cannot delete.")
            return false
        }
        do
        {
            try FileManager.default.removeItem(at: FileURL)
            return true
        }
        catch
        {
            Debug.Print("Error deleting file \(FileURL.path): error: \(error.localizedDescription)")
            return false
        }
    }
    
    /// Delete the sample image in the sample image directory.
    ///
    /// - Returns: True if the file was deleted, false if not (for any reason - not necessarily an error).
    @discardableResult public static func DeleteSampleImage() -> Bool
    {
        if !DirectoryExists(DirectoryName: SampleDirectory)
        {
            //No sample directory. Nothing to delete. Nothing deleted.
            return false
        }
        if let SampleDirURL = GetDirectoryURL(DirectoryName: SampleDirectory)
        {
            if let Images = GetFilesIn(Directory: SampleDirURL)
            {
                if Images.count < 1
                {
                    return false
                }
                return DeleteFile(Images[0])
            }
            else
            {
                return false
            }
        }
        else
        {
            return false
        }
    }
    
    /// Save the contents of the passed string to a file with the passed file name. The file is saved in BumpCamera's
    /// performance directory.
    ///
    /// - Parameters:
    ///   - SaveMe: Contains the string to save.
    ///   - FileName: The name of the file to save.
    /// - Returns: True on success, false on failure.
    @discardableResult public static func SaveStringToFile(_ SaveMe: String, FileName: String) -> Bool
    {
        if InMaximumPrivacy()
        {
            print("In Maximum Privacy mode. No writing allowed.")
            return false
        }
        let SaveDirectory = GetDirectoryURL(DirectoryName: PerformanceDirectory)
        let FinalFile = SaveDirectory?.appendingPathComponent(FileName)
        do
        {
            try SaveMe.write(to: FinalFile!, atomically: false, encoding: .utf8)
        }
        catch
        {
            Debug.Print("Error saving string to \(FinalFile!.path): error: \(error.localizedDescription)")
            return false
        }
        return true
    }
    
    /// Save the contents of the passed string to a file with the passed file name. The file will be saved in the
    /// indicated directory.
    ///
    /// - Parameters:
    ///   - SaveMe: Contains the string to save.
    ///   - FileName: The name of the file to save.
    ///   - ToDirectory: The name of the directory.
    /// - Returns: True on success, false on failure.
    @discardableResult public static func SaveStringToFile(_ SaveMe: String, FileName: String, ToDirectory: String) -> Bool
    {
        if InMaximumPrivacy()
        {
            print("In Maximum Privacy mode. No writing allowed.")
            return false
        }
        let SaveDirectory = GetDirectoryURL(DirectoryName: ToDirectory)
        let FinalFile = SaveDirectory?.appendingPathComponent(FileName)
        do
        {
            try SaveMe.write(to: FinalFile!, atomically: false, encoding: .utf8)
        }
        catch
        {
            Debug.Print("Error saving string to \(FinalFile!.path): error: \(error.localizedDescription)")
            return false
        }
        return true
    }
    
    /// Save the contents of the passed string to a file with the passed file name. The file will be saved in the
    /// indicated directory. The URL to the saved file will be returned on success.
    ///
    /// - Parameters:
    ///   - SaveMe: Contains the string to save.
    ///   - FileName: The name of the file to save.
    ///   - ToDirectory: The name of the directory.
    /// - Returns: The URL of the saved file on success, nil on error.
    @discardableResult public static func SaveStringToFileEx(_ SaveMe: String, FileName: String, ToDirectory: String) -> URL?
    {
        if InMaximumPrivacy()
        {
            print("In Maximum Privacy mode. No writing allowed.")
            return nil
        }
        let SaveDirectory = GetDirectoryURL(DirectoryName: ToDirectory)
        let FinalFile = SaveDirectory?.appendingPathComponent(FileName)
        do
        {
            try SaveMe.write(to: FinalFile!, atomically: false, encoding: .utf8)
        }
        catch
        {
            Debug.Print("Error saving string to \(FinalFile!.path): error: \(error.localizedDescription)")
            return nil
        }
        return FinalFile
    }
    
    /// Returns the current state of the maximum privacy flag in user settings.
    ///
    /// - Returns: Current maximum privacy state. If false, nothing should be written.
    private static func InMaximumPrivacy() -> Bool
    {
        return UserDefaults.standard.bool(forKey: "MaximumPrivacy")
    }
    
    /// This function should be called to delete all data in all directories created by BumpCamera. It is called by
    /// the Privacy view controller when the user enables Maximum Privacy.
    ///
    /// - Parameter IncludingDebug: Determines if the debug directory is cleared as well.
    public static func ClearAllDirectories(IncludingDebug: Bool = false)
    {
        ClearDirectory(SampleDirectory)
        ClearDirectory(ScratchDirectory)
        ClearDirectory(PerformanceDirectory)
        ClearDirectory(RuntimeDirectory)
        if IncludingDebug
        {
            ClearDirectory(DebugDirectory)
        }
    }
    
    /// Clears the built-in user temporary directory of all files.
    public static func ClearUserTempDirectory()
    {
        do
        {
            let TempDirURL = FileManager.default.temporaryDirectory
            let Contents = try FileManager.default.contentsOfDirectory(atPath: TempDirURL.path)
            
            for Content in Contents
            {
                let CurrentPath = TempDirURL.appendingPathComponent(Content)
                try FileManager.default.removeItem(at: CurrentPath)
            }
        }
        catch
        {
            Debug.Print("Error thrown when clearing temporary directory: \(error)")
        }
    }
}
