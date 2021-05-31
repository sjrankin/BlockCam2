//
//  MultiFrameCombinerFilter_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/27/21.
//

import SwiftUI

struct MultiFrameCombinerFilter_View: View
{
    @Binding var ButtonCommand: String
    @EnvironmentObject var Changed: ChangedSettings
    @State var Updated: Bool = false
    @State var Trigger: Int = Settings.GetInt(.MultiFrameCombinerCommand)
    @State var InvertTrigger: Bool = Settings.GetBool(.MultiFrameCombinerInvertCommand)
    @State var Image1Name: String = "Checkerboard2048x1024"
    var Channels = ["Brightness", "Red", "Green", "Blue", "Cyan", "Magenta", "Yellow"]
    @State var Sample0Name: String = SampleImages.GetSubSampleImageName(At: .MultiFrameSubImage0)
    @State var Sample1Name: String = SampleImages.GetSubSampleImageName(At: .MultiFrameSubImage1)
    @State var Sample0Title: String = SampleImages.GetCurrentSubSampleImageTitle(At: .MultiFrameSubImage0)
    @State var Sample1Title: String = SampleImages.GetCurrentSubSampleImageTitle(At: .MultiFrameSubImage1)
    
    var body: some View
    {
        GeometryReader
        {
            Geometry in
            VStack(alignment: .leading)
            {
                VStack(alignment: .leading)
                {
                    Text("Trigger")
                        .font(.headline)
                        .frame(alignment: .leading)
                    Text("Select the channel to trigger on to determine pixel to use.")
                        .font(.subheadline)
                        .lineLimit(2)
                        .frame(alignment: .leading)
                    Picker(selection: $Trigger, label: Text(Channels[Trigger]))
                    {
                        Text("Brightness").tag(0)
                        Text("Red").tag(1)
                        Text("Green").tag(2)
                        Text("Blue").tag(3)
                        Text("Cyan").tag(4)
                        Text("Magenta").tag(5)
                        Text("Yellow").tag(6)
                    }
                    .onChange(of: Trigger, perform:
                                {
                                    Value in
                                    print("\nTrigger channel = \(Value)")
                                    self.Trigger = Value
                                    Settings.SetInt(.MultiFrameCombinerCommand, Value)
                                    Updated.toggle()
                                })
                    .pickerStyle(MenuPickerStyle())
                    .frame(alignment: .leading)
                }
                .padding()
                
                Divider()
                    .background(Color.black)
                
                HStack
                {
                    VStack(alignment: .leading)
                    {
                        Text("Invert trigger")
                            .font(.headline)
                            .frame(width: Geometry.size.width * 0.6,
                                   alignment: .leading)
                        Text("Reverses the action of the selected trigger.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: Geometry.size.width * 0.6,
                                   alignment: .leading)
                    }
                    Toggle("", isOn: Binding(
                        get:
                            {
                                self.InvertTrigger
                            },
                        set:
                            {
                                NewValue in
                                self.InvertTrigger = NewValue
                                Settings.SetBool(.MultiFrameCombinerInvertCommand, self.InvertTrigger)
                                Updated.toggle()
                            }
                    ))
                }
                .padding()
                
                Divider()
                    .background(Color.black)
                
                VStack
                {
                    Text("Note")
                        .font(.headline)
                        .foregroundColor(.red)
                    Text("Source images must be the same width and height for this filter to work.")
                }
                .padding()
                
                Divider()
                    .background(Color.black)
                
                VStack(alignment: .center)
                {
                    HStack
                    {
                        SubSampleImage(Key: .MultiFrameSubImage0,
                                       UICommand: $ButtonCommand,
                                       ImageName: $Sample0Name,
                                       Updated: $Updated,
                                       ImageTitle: $Sample0Title)
                            .frame(width: 200, height: 200)
                            .onChange(of: Sample0Name)
                            {
                                NewValue in
                            }
                        Spacer()
                        SubSampleImage(Key: .MultiFrameSubImage1,
                                       UICommand: $ButtonCommand,
                                       ImageName: $Sample1Name,
                                       Updated: $Updated,
                                       ImageTitle: $Sample1Title)
                            .frame(width: 200, height: 200)
                            .onChange(of: Sample1Name)
                            {
                                NewValue in
                            }
                    }
                    .padding([.leading, .trailing])
                    
                    VStack
                    {
                        SubSampleResultImage(UICommand: $ButtonCommand,
                                             ResultImage: Filters.RunFilter(Images: [UIImage(named: SampleImages.GetSubSampleImageName(At: .MultiFrameSubImage0))!,
                                                                                     UIImage(named: SampleImages.GetSubSampleImageName(At: .MultiFrameSubImage1))!],
                                                                            Filter: .MultiFrameCombiner,
                                                                            $Trigger.wrappedValue)!)
                            .frame(width: 400, height: 200,
                                   alignment: .center)
                    }
                    .padding(.top, -15)
                }
                .padding(.top, -25.0)
            }
        }
        .onReceive(Changed.$ChangedFilter, perform:
                    {
                        Value in
                        if Value == BuiltInFilters.MultiFrameCombiner.rawValue
                        {
                            Updated.toggle()
                            InvertTrigger = Settings.GetBool(.MultiFrameCombinerInvertCommand)
                            Trigger = Settings.GetInt(.MultiFrameCombinerCommand)
                        }
                    })
    }
}

struct MultiFrameCombinerFilter_View_Previews: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        MultiFrameCombinerFilter_View(ButtonCommand: $NotUsed)
            .environmentObject(ChangedSettings())
    }
}
