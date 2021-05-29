//
//  SubSampleResultImage.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/28/21.
//

import Foundation
import SwiftUI

struct SubSampleResultImage: View
{
    @Binding var UICommand: String
    @State var OnLongPress: Bool = false
    @State var ShowLargePreview: Bool = false
    @State var ShowAttribution: Bool = false
    @State var ResultImage: UIImage
    
    var body: some View
    {
        VStack
        {
            Text("Result")
                .frame(alignment: .center)
                .font(.headline)
            Image(uiImage: ResultImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .background(Color.black)
                .border(Color.black, width: 0.5)
                .frame(alignment: .center)
                .gesture(
                    LongPressGesture(minimumDuration: 1.5, maximumDistance: 1.0)
                        .onEnded(
                            {
                                _ in
                                OnLongPress = true
                            }
                        )
                )
                .actionSheet(isPresented: $OnLongPress)
                {
                    ActionSheet(
                        title: Text("Sample Image Management"),
                        message: Text("Select the action to perform on the sample image"),
                        buttons:
                            [
                                .cancel(),
                                .default(Text("Save Original"))
                                {
                                    self.UICommand = UICommands.SaveOriginalSample.rawValue
                                },
                                .default(Text("Save Filtered"))
                                {
                                    self.UICommand = UICommands.SaveFilteredSample.rawValue
                                }
                            ]
                    )
                }
        }
    }
}

struct SubSampleResultImage_Preview: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        SubSampleResultImage(UICommand: $NotUsed,
                             ResultImage: UIImage(named: "Saturn2048x1024")!)
    }
}
