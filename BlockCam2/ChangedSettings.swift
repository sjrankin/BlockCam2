//
//  ChangedSettings.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/9/21.
//

import Foundation
import SwiftUI

class ChangedSettings: ObservableObject
{
    @Published var ChangedFilter: String = ""
    {
        didSet
        {
            print("ChangedFilter=\(ChangedFilter)")
        }
    }
}
