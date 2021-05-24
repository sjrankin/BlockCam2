//
//  UserSampleParentProtocol.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/23/21.
//

import Foundation
import UIKit

protocol UserSampleParentProtocol: AnyObject
{
    func Deleted(At Index: Int)
    func Edited(At Index: Int)
    func Added()
}
