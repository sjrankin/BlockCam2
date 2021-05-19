//
//  ImageTableEntryView.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/17/21.
//

import SwiftUI
import Combine

struct BultInImageTableEntryView: View
{
    @State var ImageName: String
    @State var ImageDescription: String
    @State var OverallWidth: CGFloat
    @State var ImageIsEnabled: Bool
    @State var CanDisable: Bool = true
    @State var ImageTapped: Bool = false
    @ObservedObject var BinaryValue = ToggleBinaryModel()
    
    var body: some View
    {
        HStack
        {
            Image(ImageName)
                .resizable()
                .border(Color.black, width: 0.5)
                .frame(alignment: .center)
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80, alignment: .leading)
            Text(ImageDescription)
                .font(.headline)
                .foregroundColor(ImageIsEnabled ? .black : .gray)
            Spacer()
            Toggle("Enable", isOn: $ImageIsEnabled)
                .frame(width: OverallWidth * 0.3)
                .disabled(!CanDisable)
                .onChange(of: ImageIsEnabled)
                {
                    NewValue in
                    print("\(ImageName) changed")
                }
        }
        .frame(width: OverallWidth * 0.95,
               alignment: .leading)
        .background(ImageTapped ? Color(UIColor.systemTeal) : Color.white)
        .padding([.leading, .trailing])
        .onTapGesture
        {
            ImageTapped.toggle()
        }
    }
}

class ToggleBinaryModel: ObservableObject
{
    @Published var IsOn: Bool = true
    {
        didSet
        {
            print("Switch changed to \(IsOn)")
        }
    }
}

struct SampleImageDescriptor
{
    var id: String
    var InternalName: String
    var DescriptiveName: String
    var Source: String
    var IsEnabled: Bool
}

struct BultInImageTableEntryView_Preview: PreviewProvider
{
    @State static var Sample1Enabled: Bool = true
    @State static var Sample2Enabled: Bool = true
    @State static var Sample3Enabled: Bool = true
    @State static var Sample4Enabled: Bool = true
    @State static var Sample5Enabled: Bool = true
    @State static var Sample6Enabled: Bool = true
    @State static var Sample7Enabled: Bool = true
    @State static var Sample8Enabled: Bool = true
    
    static var previews: some View
    {
        GeometryReader
        {
            Reader in
            LazyVStack
            {
                Group
                {
                    BultInImageTableEntryView(ImageName: "Sample1",
                                              ImageDescription: "Sample 1",
                                              OverallWidth: Reader.size.width,
                                              ImageIsEnabled: Sample1Enabled,
                                              CanDisable: false)
                    Divider()
                        .background(Color.black)
                    BultInImageTableEntryView(ImageName: "Sample2",
                                              ImageDescription: "Sample 2",
                                              OverallWidth: Reader.size.width,
                                              ImageIsEnabled: Sample2Enabled)
                    Divider()
                        .background(Color.black)
                    BultInImageTableEntryView(ImageName: "Sample3",
                                              ImageDescription: "Sample 3",
                                              OverallWidth: Reader.size.width,
                                              ImageIsEnabled: Sample3Enabled)
                    Divider()
                        .background(Color.black)
                    BultInImageTableEntryView(ImageName: "Sample4",
                                              ImageDescription: "Sample 4",
                                              OverallWidth: Reader.size.width,
                                              ImageIsEnabled: Sample4Enabled)
                    Divider()
                        .background(Color.black)
                }
                Group
                {
                    BultInImageTableEntryView(ImageName: "Sample5",
                                              ImageDescription: "Sample 5",
                                              OverallWidth: Reader.size.width,
                                              ImageIsEnabled: Sample5Enabled)
                    Divider()
                        .background(Color.black)
                    BultInImageTableEntryView(ImageName: "Sample6",
                                              ImageDescription: "Sample 6",
                                              OverallWidth: Reader.size.width,
                                              ImageIsEnabled: Sample6Enabled)
                    Divider()
                        .background(Color.black)
                    BultInImageTableEntryView(ImageName: "Sample7",
                                              ImageDescription: "Sample 7",
                                              OverallWidth: Reader.size.width,
                                              ImageIsEnabled: Sample7Enabled)
                    Divider()
                        .background(Color.black)
                    BultInImageTableEntryView(ImageName: "Sample8",
                                              ImageDescription: "Sample 8",
                                              OverallWidth: Reader.size.width,
                                              ImageIsEnabled: Sample8Enabled)
                    Divider()
                        .background(Color.black)
                }
            }
        }
    }
}
