//
//  +VideoProcessing.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/26/21.
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

extension LiveViewController
{
    /// Run the current filter against the passed video.
    /// - Parameter VideoURL: The URL of the video to process.
    /// - Parameter ScratchName: Not currently used.
    func ApplyFilterToVideo(_ VideoURL: URL, ScratchName: String)
    {
        let Asset = AVAsset(url: VideoURL)
        let Composition = AVVideoComposition(asset: Asset,
                                             applyingCIFiltersWithHandler:
                                                {
                                                    Request in
                                                    let Source = Request.sourceImage.clampedToExtent()
                                                    let Output = Filters.RunFilter2(On: Source,
                                                                                    Extent: Request.sourceImage.extent)!
                                                    Request.finish(with: Output, context: nil)
                                                })
        let SomeName = "\(UUID().uuidString).mov"
        let OutputURL = NSTemporaryDirectory().appendingFormat(SomeName)
        let ExportURL = URL(fileURLWithPath: OutputURL)
        let Export = AVAssetExportSession(asset: Asset,
                                          presetName: AVAssetExportPresetHighestQuality)
        Export?.outputFileType = AVFileType.mov
        Export?.outputURL = ExportURL
        Export?.videoComposition = Composition
        UIDelegate?.ShowShortMessage(With: "Processing Video")
        Export?.exportAsynchronously
        {
            PHPhotoLibrary.shared().performChanges(
                {
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: ExportURL)
                })
            {
                Saved, Error in
                if Saved
                {
                    self.UIDelegate?.HideShortMessage()
                    Debug.Print("Saved video")
                }
                if let error = Error
                {
                    self.UIDelegate?.HideShortMessage()
                    Debug.Print("Error: \(error)")
                }
            }
        }
    }
}
