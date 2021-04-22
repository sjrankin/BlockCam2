//
//  ObservableArray.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/21/21.
//

import Foundation
import SwiftUI

/// Holds an observable array of strings.
class ObservableArray: ObservableObject
{
    /// The data being held.
    @Published var Items = [String]()
    
    init()
    {
    }
    
    /// Initializer.
    /// - Parameter Items: Array of strings to add.
    init(Items: [String])
    {
        self.Items = Items
    }
}
