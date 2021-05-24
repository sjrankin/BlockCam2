//
//  UserSampleProtocol.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/23/21.
//

import Foundation
import UIKit

protocol UserSampleProtocol: AnyObject
{
    var Parent: UserSampleParentProtocol? {get}
    func SetImageIndex(_ Index: Int)
}
