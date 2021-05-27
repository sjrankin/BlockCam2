//
//  NSNotification.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/25/21.
//

import Foundation

extension NSNotification
{
    static let TitleUpdate = NSNotification.Name.init("TitleUpdate")
    static let FilterUpdate = NSNotification.Name.init("FilterUpdate")
    static let GroupUpdate = NSNotification.Name.init("GroupUpdate")
    static let ProgressUpdate = NSNotification.Name.init("ProgressUpdate")
}
