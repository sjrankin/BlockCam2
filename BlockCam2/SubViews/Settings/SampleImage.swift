//
//  SampleImage.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/5/21.
//

import Foundation
import SwiftUI

struct SampleImage: View
{
    @State var ImageName: String = Utility.GetSampleImageName()
    //@Binding var FilterOptions: [FilterOptions: Any]
    @State var Filter: BuiltInFilters
    var EnableImageChange: Bool = true
    @State var Updated: Bool
    
    var body: some View
    {
        Image(uiImage: Filters.RunFilter(On: UIImage(named: $ImageName.wrappedValue)!,
                                         Filter: Filter)!)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .background(Color.black)
            .gesture(
                DragGesture(minimumDistance: 5, coordinateSpace: .local)
                    .onEnded(
                        {
                            value in
                            if value.translation.width < 0
                            {
                                //swiped left
                                if EnableImageChange
                                {
                                    ImageName = Utility.DecrementSampleImageName()
                                }
                            }
                            if value.translation.width > 0
                            {
                                //swiped right
                                if EnableImageChange
                                {
                                    ImageName = Utility.IncrementSampleImageName()
                                }
                            }
                        })
            )
    }
}

struct SampleImage_Preview: PreviewProvider
{
    #if false
    @State static var Options: [FilterOptions: Any] =
        [.Color: Settings.GetColor(.ColorMonochromeColor) as Any]
    #endif
    
    static var previews: some View
    {
        #if true
        SampleImage(Filter: .Passthrough, Updated: false)
        #else
        SampleImage(FilterOptions: $Options, Filter: .Passthrough)
            .frame(width: 300, height: 300, alignment: .center)
        #endif
    }
}
