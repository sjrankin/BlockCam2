//
//  BlockCam2App.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/13/21.
//

import SwiftUI

@main struct BlockCam2App: App
{
    init()
    {
        Settings.Initialize()
        if Settings.IsFalse(For: .ClosedCleanly)
        {
            Debug.Print("Previous instantiation did not close cleanly.")
            Settings.SetString(.CurrentFilter, "")
            Settings.SetString(.CurrentGroup, "")
        }
    }
    
    var body: some Scene
    {
        WindowGroup
        {
            ContentView().environmentObject(ChangedSettings())
        }
    }
}
