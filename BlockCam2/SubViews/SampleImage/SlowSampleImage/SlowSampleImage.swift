//
//  SlowSampleImage.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/17/21.
//

import Foundation
import SwiftUI

struct SlowSampleImage: View
{
    @Binding var UICommand: String
    @State var OnLongPress: Bool = false
    @State var ShowLargePreview: Bool = false
    @State var ImageName: String = SampleImages.GetSampleImageName()
    @State var Filter: BuiltInFilters
    var EnableImageChange: Bool = true
    @State var Updated: Bool
    @Binding var Completed: Bool
    
    var body: some View
    {
        VStack
        {
            Text(SampleImages.GetCurrentSampleImageName(From: $ImageName.wrappedValue))
                .frame(alignment: .center)
                .font(.subheadline)
                .foregroundColor(.gray)
            Image(uiImage: Filters.RunFilter(On: UIImage(named: $ImageName.wrappedValue)!,
                                             Filter: Filter, Block:
                                                {Result in
                                                    Completed = Result
                                                    print("Filter reports completion")
                                                }
            )!)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .background(Color.black)
                .border(Color.black, width: 0.5)
                .frame(alignment: .center)
                .help("Swipe left or right to change the sample image. Double tap to enlarge.")
                .gesture(
                    DragGesture(minimumDistance: 3, coordinateSpace: .local)
                        .onEnded(
                            {
                                value in
                                if value.translation.width < 0
                                {
                                    //swiped left
                                    if EnableImageChange
                                    {
                                        ImageName = SampleImages.IncrementSampleImageName()
                                    }
                                }
                                if value.translation.width > 0
                                {
                                    //swiped right
                                    if EnableImageChange
                                    {
                                        ImageName = SampleImages.DecrementSampleImageName()
                                    }
                                }
                            })
                )
                .gesture(
                    TapGesture(count: 2)
                        .onEnded(
                            {
                                ShowLargePreview = true
                            }
                        )
                )
                .gesture(
                    LongPressGesture(minimumDuration: 1.5, maximumDistance: 1.0)
                        .onEnded(
                            {
                                _ in
                                OnLongPress = true
                            }
                        )
                )
                .sheet(isPresented: self.$ShowLargePreview)
                {
                    LargeSampleImage(UICommand: $UICommand,
                                     ImageToView: UIImage(named: ImageName)!,
                                     Filter: Filter,
                                     PageTitle: "Enlarged: \(Filter.rawValue)")
                }
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
            #if os(iOS)
            Text("Swipe left or right to change the sample image. Double tap to enlarge.")
                .multilineTextAlignment(.center)
                .frame(alignment: .center)
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding()
            #endif
        }
    }
}

struct SlowSampleImage_Preview: PreviewProvider
{
    @State static var NotUsed: String = ""
    @State static var Completed: Bool = false
    
    static var previews: some View
    {
        SlowSampleImage(UICommand: $NotUsed,
                        Filter: .Passthrough,
                        Updated: false,
                        Completed: $Completed)
    }
}
