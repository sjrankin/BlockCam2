//
//  CameraButton.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/11/21.
//

import Foundation
import SwiftUI

struct CameraIcon: View
{
    @State var IsSaveIcon: Bool
    
    var body: some View
    {
        Image(systemName: IsSaveIcon ? "square.and.arrow.down" : "camera")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 32, height: 32, alignment: .center)
            .foregroundColor(.yellow)
    }
}

struct PhotoActionButton: View
{
    @Binding var ImageName: String
    
    var body: some View
    {
        Image(systemName: ImageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 32, height: 32, alignment: .center)
            .foregroundColor(.yellow)
    }
}
