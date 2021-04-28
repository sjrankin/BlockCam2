//
//  MainUIButtons.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/28/21.
//

import Foundation
import SwiftUI

struct EditFilterIcon: View
{
    var body: some View
    {
        Image(systemName: "slider.horizontal.3")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 32, height: 32, alignment: .center)
            .foregroundColor(.yellow)
    }
}

struct SharingIcon: View
{
    var body: some View
    {
        Image(systemName: "square.and.arrow.up")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 32, height: 32, alignment: .center)
            .foregroundColor(.yellow)
    }
}

struct CameraIcon: View
{
    var body: some View
    {
        Image(systemName: "camera")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 32, height: 32, alignment: .center)
            .foregroundColor(.yellow)
    }
}

struct FiltersIcon: View
{
    @Binding var IsHighlighted: Bool
    @Binding var DoRotate: Bool
    
    var body: some View
    {
        Image(systemName: "camera.filters")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 32, height: 32, alignment: .center)
            .foregroundColor(!IsHighlighted ? .black : .yellow)
            .rotationEffect(.degrees(!DoRotate ? 360.0 : 0.0))
            .animation(!DoRotate ? Animation.linear(duration: 10.0)
                        .repeatForever(autoreverses: false) : Animation.default)
    }
}

struct GearIcon: View
{
    var body: some View
    {
        Image(systemName: "gearshape")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 32, height: 32, alignment: .center)
            .foregroundColor(.yellow)
    }
}

struct SelfieIcon: View
{
    @State var IconName: String = ""
    
    init(_ IconName: String)
    {
        self.IconName = IconName
    }
    
    var body: some View
    {
        Image(systemName: IconName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 32, height: 32, alignment: .center)
            .foregroundColor(.yellow)
    }
}

struct BackCameraIcon: View
{
    var body: some View
    {
        Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 32, height: 32, alignment: .center)
            .foregroundColor(.yellow)
    }
}

struct PhotoLibraryIcon: View
{
    var body: some View
    {
        Image(systemName: "photo.on.rectangle.angled")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 32, height: 32, alignment: .center)
            .foregroundColor(.yellow)
    }
}

