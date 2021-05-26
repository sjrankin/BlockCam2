//
//  Sharing.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/24/21.
//

import Foundation
import UIKit

extension LiveViewController: UIActivityItemSource
{
    /// Run the share sheet to share the most recently filtered image.
    func Share()
    {
        let Items: [Any] = [self]
        let ACV = UIActivityViewController(activityItems: Items, applicationActivities: nil)
        ACV.popoverPresentationController?.sourceView = self.view
        ACV.popoverPresentationController?.sourceRect = self.view.frame
        ACV.popoverPresentationController?.canOverlapSourceViewRect = true
        ACV.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        self.present(ACV, animated: true, completion: nil)
    }
    
    /// Returns the subject line for possible use when exporting the image.
    /// - Parameter activityViewController: Not used.
    /// - Parameter subjectForActivityType: Not used.
    /// - Returns: Subject line.
    public func activityViewController(_ activityViewController: UIActivityViewController,
                                       subjectForActivityType activityType: UIActivity.Type?) -> String
    {
        return "BlockCam Image"
    }
    
    /// Determines the type of object to export.
    /// - Parameter activityViewController: Not used.
    /// - Returns: Instance of the type to export. In our case, a `UIImage`.
    public func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any
    {
        return UIImage()
    }
    
    /// Returns the object to export (the type of which is determined in `activityViewControllerPlaceholderItem`.
    /// - Parameter activityViewController: Not used.
    /// - Parameter itemForActivityType: Determines how the user wants to export the image. In our case, we support
    ///                                  anything that accepts an image.
    /// - Returns: The image of the gradient.
    public func activityViewController(_ activityViewController: UIActivityViewController,
                                       itemForActivityType activityType: UIActivity.ActivityType?) -> Any?
    {
        guard let Target = activityType else
        {
            return nil
        }
        guard let Generated: UIImage = ImageToExport else
        {
            return nil
        }
        
        switch Target
        {
            case .postToTwitter,
                 .airDrop,
                 .assignToContact,
                 .copyToPasteboard,
                 .mail,
                 .message,
                 .postToFlickr,
                 .postToWeibo,
                 .postToTwitter,
                 .postToFacebook,
                 .postToTencentWeibo,
                 .print,
                 .markupAsPDF,
                 .message,
                 .saveToCameraRoll:
                return Generated
                
            default:
                return Generated
        }
    }
}
