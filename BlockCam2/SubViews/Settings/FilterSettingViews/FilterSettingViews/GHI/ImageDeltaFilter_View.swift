//
//  ImageDeltaFilter_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/29/21.
//

import Foundation
import SwiftUI

struct ImageDeltaFilter_View: View
{
    @Binding var ButtonCommand: String
    @EnvironmentObject var Changed: ChangedSettings
    @State var Updated: Bool = false
    @State var EnableEffective: Bool = Settings.GetBool(.ImageDeltaUseEffectiveColor)
    @State var Method: Int = Settings.GetInt(.ImageDeltaCommand)
    @State var EFColor: UIColor = Settings.GetColor(.ImageDeltaEffectiveColor, UIColor.yellow)
    @State var BGColor: UIColor = Settings.GetColor(.ImageDeltaBackground, UIColor.black)
    @State var Image1Name: String = "Checkerboard2048x1024"
    var Commands = ["Absolute Delta", "Only Delta", "Only Same", "Standard", "Primary Delta"]
    @State var Sample0Name: String = SampleImages.GetSubSampleImageName(At: .ImageDeltaSubImage0)
    @State var Sample1Name: String = SampleImages.GetSubSampleImageName(At: .ImageDeltaSubImage1)
    @State var Sample0Title: String = SampleImages.GetCurrentSubSampleImageTitle(At: .ImageDeltaSubImage0)
    @State var Sample1Title: String = SampleImages.GetCurrentSubSampleImageTitle(At: .ImageDeltaSubImage1)
    @State var Threshold: Double = Settings.GetDouble(.ImageDeltaThreshold, 0.0)
    @State var ThresholdString: String = Settings.GetDouble(.ImageDeltaThreshold, 0.0).RoundedTo(2, PadTo: 2)
    @State var ShowFilterInfo: Bool = false
    
    var body: some View
    {
        GeometryReader
        {
            Geometry in
            VStack(alignment: .leading)
            {
                VStack(alignment: .leading)
                {
                    HStack
                    {
                        VStack(alignment: .leading)
                        {
                    Text("Method")
                        .font(.headline)
                        .frame(alignment: .leading)
                    Text("Select the method to use to create the image delta.")
                        .font(.subheadline)
                        .lineLimit(2)
                        .foregroundColor(.gray)
                        .frame(alignment: .leading)
                        }
                        Button(action:
                                {
                                    ShowFilterInfo = true
                                },
                               label:
                                {
                            Image(systemName: "info.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundColor(.red)

                        })
                    }
                    Picker(selection: $Method, label: Text(Commands[Method]))
                    {
                        Text("Absolute Delta").tag(0)
                        Text("Only Delta").tag(1)
                        Text("Only Same").tag(2)
                        Text("Standard").tag(3)
                        Text("Primary Delta").tag(4)
                    }
                    .onChange(of: Method, perform:
                                {
                                    Value in
                                    self.Method = Value
                                    Settings.SetInt(.ImageDeltaCommand, Value)
                                    Updated.toggle()
                                })
                    .pickerStyle(MenuPickerStyle())
                    .frame(alignment: .leading)
                    .alert(isPresented: $ShowFilterInfo)
                    {
                        Alert(title: Text("Note"),
                              message: Text("Source images must be the same width and height for this filter to work."),
                              dismissButton: .default(Text("OK")))
                    }
                }
                .padding()
                
                Divider()
                    .background(Color.black)

                VStack(alignment: .leading)
                {
                    HStack
                    {
                        VStack(alignment: .leading)
                        {
                            Text("Background Color")
                                .font(.headline)
                                .frame(alignment: .leading)
                            Text("Background color for transparent pixels")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(width: Geometry.size.width * 0.65,
                                       alignment: .leading)
                        }
                        ColorPicker("",
                                    selection: Binding(
                                        get:
                                            {
                                                Color(self.BGColor)
                                            },
                                        set:
                                            {
                                                NewValue in
                                                self.BGColor = UIColor(NewValue)
                                                Settings.SetColor(.ImageDeltaBackground, self.BGColor)
                                                Updated.toggle()
                                            }
                                    ))
                    }
                    .padding([.leading, .trailing])
                    HStack
                    {
                        VStack(alignment: .leading)
                        {
                            Text("Effective Color")
                                .font(.headline)
                                .frame(alignment: .leading)
                            Text("Color for showing deltas when Standard is used.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(width: Geometry.size.width * 0.65,
                                       alignment: .leading)
                        }
                        ColorPicker("",
                                    selection: Binding(
                                        get:
                                            {
                                                Color(self.EFColor)
                                            },
                                        set:
                                            {
                                                NewValue in
                                                self.EFColor = UIColor(NewValue)
                                                Settings.SetColor(.ImageDeltaEffectiveColor, self.EFColor)
                                                Updated.toggle()
                                            }
                                    ))
                    }
                    .padding()
                }
                
                Divider()
                    .background(Color.black)
                
                HStack
                {
                        VStack(alignment: .leading)
                        {
                            Text("Enable effective color")
                                .font(.headline)
                                .frame(alignment: .leading)
                            Text("Enabled coloration for effective areas for standard deltas.")
                                .lineLimit(2)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(width: Geometry.size.width * 0.65,
                                       alignment: .leading)
                        }
                    Toggle("", isOn: Binding(
                            get:
                                {
                                    self.EnableEffective
                                },
                        set:
                            {
                                NewValue in
                                self.EnableEffective = NewValue
                                Settings.SetBool(.ImageDeltaUseEffectiveColor, self.EnableEffective)
                                Updated.toggle()
                            }
                    ))
                }
                .padding([.leading, .trailing])
                
                Divider()
                    .background(Color.black)
                
                VStack(alignment: .leading)
                {
                    VStack(alignment: .leading)
                    {
                        Text("Threshold")
                            .font(.headline)
                            .frame(alignment: .leading)
                        Text("Determines when to use the background color. If greatest channel is less, color is used.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(3)
                            .frame(width: Geometry.size.width * 0.85,
                                   alignment: .leading)
                    }
                    HStack
                    {
                        Slider(value: Binding(
                            get:
                                {
                                    self.Threshold
                                },
                            set:
                                {
                                    NewValue in
                                    self.Threshold = NewValue
                                    Settings.SetDouble(.ImageDeltaThreshold, self.Threshold)
                                    Updated.toggle()
                                    ThresholdString = self.Threshold.RoundedTo(2, PadTo: 2)
                                }
                        ), in: 0.0 ... 1.0)
                        .frame(width: Geometry.size.width * 0.75)
                        Text($ThresholdString.wrappedValue)
                            .frame(width: Geometry.size.width * 0.2)
                            .font(Font.system(.body, design: .monospaced).monospacedDigit())
                    }
                }
                .padding([.leading, .trailing])
                
                Divider()
                    .background(Color.black)
                
                VStack(alignment: .center)
                {
                    HStack
                    {
                        SubSampleImage(Key: .ImageDeltaSubImage0,
                                       UICommand: $ButtonCommand,
                                       ImageName: $Sample0Name,
                                       Updated: $Updated.wrappedValue,
                                       ImageTitle: $Sample0Title)
                            .frame(width: 200, height: 200)
                            .onChange(of: Sample0Name)
                            {
                                NewValue in
                            }
                        Spacer()
                        SubSampleImage(Key: .ImageDeltaSubImage1,
                                       UICommand: $ButtonCommand,
                                       ImageName: $Sample1Name,
                                       Updated: $Updated.wrappedValue,
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
                                             ResultImage: Filters.RunFilter(Images: [UIImage(named: SampleImages.GetSubSampleImageName(At: .ImageDeltaSubImage0))!,
                                                                                     UIImage(named: SampleImages.GetSubSampleImageName(At: .ImageDeltaSubImage1))!],
                                                                            Filter: .ImageDelta,
                                                                            $Method.wrappedValue)!)
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
                        if Value == BuiltInFilters.ImageDelta.rawValue
                        {
                            Updated.toggle()
                        }
                    })
    }
}

struct ImageDeltaFilter_Previews: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        ImageDeltaFilter_View(ButtonCommand: $NotUsed)
            .environmentObject(ChangedSettings())
    }
}
