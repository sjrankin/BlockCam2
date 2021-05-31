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
    @State var EnableFilter: Bool = true
    @State var ShowHelp: Bool = false
    @State var ShowAttribution: Bool = false
    
    var body: some View
    {
        GeometryReader
        {
            Geometry in
            NavigationView
            {
                VStack(alignment: .center)
                {
                    Spacer()
                    HStack
                    {
                        VStack
                        {
                            Text("Show filter")
                                .frame(width: Geometry.size.width * 0.7,
                                       alignment: .leading)
                            Text("View sample with filter.")
                                .font(.subheadline)
                                .lineLimit(3)
                                .foregroundColor(.gray)
                                .frame(width: Geometry.size.width * 0.7,
                                        alignment: .leading)
                        }
                    Toggle("", isOn: $EnableFilter)
                    }
                    .padding()
                    
                    Image(uiImage: Filters.RunFilter(On: ImageToView, Filter: EnableFilter ? Filter : .Passthrough)!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .background(Color.gray)
                        .border(Color.black, width: 1.0)
                        .frame(width: Geometry.size.width * 0.95,
                               height: Geometry.size.height * 0.75,
                               alignment: .center)
                        .gesture(
                            DragGesture(minimumDistance: 3, coordinateSpace: .local)
                                .onEnded(
                                    {
                                        value in
                                        if value.translation.width < 0
                                        {
                                            //swiped left
                                            ImageName = SampleImages.IncrementSampleImageName()
                                            ImageToView = UIImage(named: ImageName)!
                                        }
                                        if value.translation.width > 0
                                        {
                                            //swiped right
                                            ImageName = SampleImages.IncrementSampleImageName()
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
                                            Settings.SetString(.SampleImageFilter, Filter.rawValue)
                                            self.UICommand = UICommands.SaveOriginalSample.rawValue
                                        },
                                        .default(Text("Save Filtered"))
                                        {
                                            Settings.SetString(.SampleImageFilter, Filter.rawValue)
                                            self.UICommand = UICommands.SaveFilteredSample.rawValue
                                        },
                                        .default(Text("Show Attribution"))
                                        {
                                            ShowAttribution.toggle()
                                        }
                                    ]
                            )
                        }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle(PageTitle)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing)
                    {
                    Button(action:
                            {
                                self.Presentation.wrappedValue.dismiss()
                            })
                    {
                        Text("Close")
                    }
                    }
                    ToolbarItem(placement: .navigationBarLeading)
                    {
                        Button(action:
                                {
                                    ShowHelp = true
                                })
                        {
                            Image(systemName: "questionmark.circle.fill")
                        }
                    }
                }
                .alert(isPresented: $ShowHelp)
                {
                    Alert(title: Text("Help"),
                          message: Text("Tap the image to dismiss this view. Swipe the image left or right to see other sample images. Use the toggle button to see the sample with or without the filter."),
                          dismissButton: .default(Text("OK")))
                }
                .alert(isPresented: $ShowAttribution)
                {
                    Alert(title: Text("Attribution"),
                          message: Text(SampleImages.CurrentSample.Attribution),
                          dismissButton: .default(Text("OK")))
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
