//
//  HistogramTransferFilter_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 6/2/21.
//

import SwiftUI

//
//  MultiFrameCombinerFilter_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/27/21.
//

import SwiftUI

struct HistogramTransferFilter_View: View
{
    @Binding var ButtonCommand: String
    @EnvironmentObject var Changed: ChangedSettings
    @State var Updated: Bool = false
    
    var body: some View
    {
        GeometryReader
        {
            Geometry in
            ScrollView
            {
                VStack(alignment: .leading)
                {
                    Text("Histogram Source")
                        .font(.headline)
                        .frame(width: Geometry.size.width * 0.85,
                               alignment: .leading)
                    Text("The image to use as the source of the histogram to transfer to other images.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .frame(width: Geometry.size.width * 0.85,
                               alignment: .leading)
                }
                .frame(alignment: .leading)
                .padding()
                
                VStack(alignment: .center)
                {
                    SelectedImageView(Updated: $Updated)
                        .frame(width: 300, height: 300,
                               alignment: .center)
                }
                
                Divider()
                    .background(Color.black)
                
                VStack(alignment: .center)
                {
                    SampleImage(UICommand: $ButtonCommand,
                                Filter: .HistogramTransfer,
                                Updated: $Updated.wrappedValue)
                        .frame(width: 300, height: 300,
                               alignment: .center)
                }
            }
        }
        .onReceive(Changed.$ChangedFilter, perform:
                    {
                        Value in
                        if Value == BuiltInFilters.HistogramTransfer.rawValue
                        {
                            Updated.toggle()
                        }
                    })
    }
}

struct HistogramTransferFilter_Previews: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        HistogramTransferFilter_View(ButtonCommand: $NotUsed)
            .environmentObject(ChangedSettings())
    }
}
