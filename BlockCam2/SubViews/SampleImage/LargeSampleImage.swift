//
//  LargeSampleImage.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/10/21.
//

import Foundation
import SwiftUI

struct LargeSampleImage: View
{
    @Environment(\.presentationMode) var Presentation
    @Binding var UICommand: String
    @State var OnLongPress: Bool = false
    @State var ImageToView: UIImage
    @State var Filter: BuiltInFilters
    @State var PageTitle: String
    @State var ImageName: String = "Sample1"
    
    var body: some View
    {
        GeometryReader
        {
            Geometry in
            NavigationView
            {
                VStack(alignment: .center)
                {
                    Image(uiImage: Filters.RunFilter(On: ImageToView, Filter: Filter)!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .background(Color.gray)
                        .border(Color.black, width: 1.0)
                        .frame(width: Geometry.size.width * 0.9,
                               height: Geometry.size.height * 0.8,
                               alignment: .center)
                        .gesture(
                            DragGesture(minimumDistance: 3, coordinateSpace: .local)
                                .onEnded(
                                    {
                                        value in
                                        if value.translation.width < 0
                                        {
                                            //swiped left
                                            ImageName = Utility.IncrementSampleImageName()
                                            ImageToView = UIImage(named: ImageName)!
                                        }
                                        if value.translation.width > 0
                                        {
                                            //swiped right
                                            ImageName = Utility.IncrementSampleImageName()
                                            ImageToView = UIImage(named: ImageName)!
                                        }
                                    })
                        )
                        .gesture(
                            TapGesture(count: 1)
                                .onEnded(
                                    {
                                        self.Presentation.wrappedValue.dismiss()
                                    }
                                )
                        )
                        .gesture(
                            LongPressGesture(minimumDuration: 1.0, maximumDistance: 1.0)
                                .onEnded
                                {
                                    Value in
                                    OnLongPress = true
                                }
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
                    #if os(iOS)
                    Text("Swipe left or right to change the sample image. Tap to reduce.")
                        .multilineTextAlignment(.center)
                        .frame(alignment: .center)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding()
                    Spacer()
                    #endif
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle(PageTitle)
                .toolbar {
                    Button(action:
                            {
                                self.Presentation.wrappedValue.dismiss()
                            })
                    {
                        Text("Close")
                    }
                }
            }
            .padding()
            .frame(width: Geometry.size.width, height: Geometry.size.height)
        }
    }
}

struct LargeSampleImage_Preview: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        LargeSampleImage(UICommand: $NotUsed,
                         ImageToView: UIImage(named: "Sample1")!,
                         Filter: .EdgeWork,
                         PageTitle: "Enlarged: Edge Work")
    }
}
