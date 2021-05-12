//
//  ImageSourceButton.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/11/21.
//

import Foundation
import SwiftUI


struct ImageSourceButton: View
{
    @Binding var Source: Int
    var IconImages = ["camera.aperture", "photo.on.rectangle.angled"]
    
    var body: some View
    {
        Image(systemName: IconImages[Source])
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 32, height: 32, alignment: .center)
            .foregroundColor(.yellow)
            .gesture(
                DragGesture(minimumDistance: 3, coordinateSpace: .local)
                    .onEnded(
                        {
                            Value in
                            if Value.translation.height < 0
                            {
                                //swiped up
                                Source = Source + 1
                                if Source > IconImages.count - 1
                                {
                                    Source = 0
                                }
                            }
                            if Value.translation.height > 0
                            {
                                Source = Source - 1
                                if Source < 0
                                {
                                    Source = IconImages.count - 1
                                }
                            }
                        }
                    )
            )
    }
}
