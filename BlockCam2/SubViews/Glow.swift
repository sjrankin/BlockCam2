//
//  Glow.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/24/21.
//

import SwiftUI

extension View
{
    func Glow(GlowColor: Color = .yellow, Radius: CGFloat = 5) -> some View
    {
        self
            .shadow(color: GlowColor, radius: Radius / 3)
            .shadow(color: GlowColor, radius: Radius / 3)
            .shadow(color: GlowColor, radius: Radius / 3)
    }
}
