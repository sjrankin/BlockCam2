//
//  ColorRangeFilter_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/29/21.
//

import Foundation
import SwiftUI

struct ColorRangeFilter_View: View
{
    @Binding var ButtonCommand: String
    @EnvironmentObject var Changed: ChangedSettings
    @State var Updated: Bool = false
    @State var StartRange: Double = Settings.GetDouble(.ColorRangeStart, 0.35).RoundedTo(2)
    @State var StartString: String = "\(Int(Settings.GetDouble(.ColorRangeStart, 0.35) * 360.0))°"
    @State var EndRange: Double = Settings.GetDouble(.ColorRangeEnd, 0.55).RoundedTo(2)
    @State var EndString: String = "\(Int(Settings.GetDouble(.ColorRangeEnd, 0.55) * 360.0))°"
    @State var InvertRange: Bool = Settings.GetBool(.ColorRangeInvertRange)
    @State var OutOfRangeAction: Int = Settings.GetInt(.ColorRangeOutOfRangeAction)
    @State var OutOfRangeColor: UIColor = Settings.GetColor(.ColorRangeOutOfRangeColor,
                                                            UIColor.green)
    var ActionNames = ["Mean Grayscale", "Greatest Grayscale", "Smallest Grayscale",
                       "Invert Hue", "Invert Brightness", "Reduce Brightness",
                       "Reduce Saturation", "Use Your Color"]
    @State var SelectedColorRange: Int = Settings.GetInt(.ColorRangePredefinedRangesIndex)
    var ColorRanges: [(String, Double, Double, Bool)] =
    [
        ("Free Form", 0.0, 0.0, false),
        ("Red", 355.0 / 360.0, 10.0 / 360.0, true),
        ("Red-Orange", 11.0 / 360.0, 20.0 / 360.0, false),
        ("Orange-Brown", 21.0 / 360.0, 40.0 / 360.0, false),
        ("Orange-Yellow", 41.0 / 360.0, 50.0 / 360.0, false),
        ("Yellow", 51.0 / 360.0, 60.0 / 360.0, false),
        ("Yellow-Green", 61.0 / 360.0, 80.0 / 360.0, false),
        ("Green", 81.0 / 360.0, 140.0 / 360.0, false),
        ("Green-Cyan", 170.0 / 360.0, 200.0 / 360.0, false),
        ("Cyan-Blue", 201.0 / 360.0, 220.0 / 360.0, false),
        ("Pink", 331.0 / 360.0, 345.0 / 360.0, false),
        ("Pink-Red", 346.0 / 360.0, 355.0 / 360.0, false)
    ]
    
    var body: some View
    {
        GeometryReader
        {
            Geometry in
            ScrollView
            {
                VStack(alignment: .leading)
                {
                    Group
                    {
                        VStack(alignment: .leading)
                        {
                            Text("Start")
                                .font(.headline)
                                .frame(width: Geometry.size.width * 0.8,
                                       alignment: .leading)
                            Text("Start of the hue range to include")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(width: Geometry.size.width * 0.8,
                                       alignment: .leading)
                            HStack
                            {
                                Slider(value: Binding(
                                    get:
                                        {
                                            self.StartRange
                                        },
                                    set:
                                        {
                                            NewValue in
                                            self.StartRange = NewValue.RoundedTo(2)
                                            self.StartString = "\(Int(NewValue * 360.0))°"
                                            Settings.SetDouble(.ColorRangeStart, self.StartRange)
                                            if NewValue > EndRange
                                            {
                                                EndRange = NewValue
                                                EndString = "\(Int(NewValue * 360.0))°"
                                                Settings.SetDouble(.ColorRangeEnd, self.StartRange)
                                            }
                                            Updated.toggle()
                                        }
                                ),
                                in: 0.0 ... 1.0)
                                .frame(width: Geometry.size.width * 0.75)
                                Text($StartString.wrappedValue)
                                    .frame(width: Geometry.size.width * 0.2)
                                    .font(Font.system(.body, design: .monospaced).monospacedDigit())
                            }
                        }
                        .padding([.top, .leading, .trailing])
                    }
                     
                    Group
                    {
                        VStack(alignment: .leading)
                        {
                            Text("End")
                                .font(.headline)
                                .frame(width: Geometry.size.width * 0.8,
                                       alignment: .leading)
                            Text("End of the hue range to include")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(width: Geometry.size.width * 0.8,
                                       alignment: .leading)
                            HStack
                            {
                                Slider(value: Binding(
                                    get:
                                        {
                                            self.EndRange
                                        },
                                    set:
                                        {
                                            NewValue in
                                            self.EndRange = NewValue.RoundedTo(2)
                                            self.EndString = "\(Int(NewValue * 360.0))°"
                                            Settings.SetDouble(.ColorRangeEnd, self.EndRange)
                                            if NewValue < StartRange
                                            {
                                                StartRange = NewValue
                                                StartString = "\(Int(NewValue * 360.0))°"
                                                Settings.SetDouble(.ColorRangeStart, self.EndRange)
                                            }
                                            Updated.toggle()
                                        }
                                ),
                                in: 0.0 ... 1.0)
                                .frame(width: Geometry.size.width * 0.75)
                                Text($EndString.wrappedValue)
                                    .frame(width: Geometry.size.width * 0.2)
                                    .font(Font.system(.body, design: .monospaced).monospacedDigit())
                            }
                        }
                        .padding([.leading, .trailing])
                        
                        HStack
                        {
                            Text("Pre-defined color range")
                                .font(.headline)
                                .frame(width: Geometry.size.width * 0.5)
                            Spacer()
                            Picker(ColorRanges[$SelectedColorRange.wrappedValue].0, selection: Binding(
                                get:
                                    {
                                        self.SelectedColorRange
                                    },
                                set:
                                    {
                                        NewValue in
                                        self.SelectedColorRange = NewValue
                                        if NewValue == 0
                                        {
                                            InvertRange = false
                                            Settings.SetBool(.ColorRangeInvertRange, false)
                                        }
                                        else
                                        {
                                            InvertRange = ColorRanges[NewValue].3
                                            Settings.SetBool(.ColorRangeInvertRange, InvertRange)
                                            EndRange = ColorRanges[NewValue].2
                                            EndString = "\(Int(EndRange * 360.0))°"
                                            StartRange = ColorRanges[NewValue].1
                                            StartString = "\(Int(StartRange * 360.0))°"
                                            Settings.SetDouble(.ColorRangeEnd, EndRange)
                                            Settings.SetDouble(.ColorRangeStart, StartRange)
                                            Settings.SetInt(.ColorRangePredefinedRangesIndex, NewValue)
                                        }
                                        Updated.toggle()
                                    }
                            ))
                            {
                                ForEach(0 ..< ColorRanges.count, id: \.self)
                                {
                                    Index in
                                    Text(ColorRanges[Index].0).tag(Index)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: Geometry.size.width * 0.5)
                        }
                        //.padding([.leading, .trailing])
                        
                        Divider()
                            .background(Color.black)
                    }
                    
                    Group
                    {
                        #if true
                        HStack
                        {
                            VStack(alignment: .leading)
                            {
                                Text("Invert")
                                    .font(.headline)
                                    .frame(width: Geometry.size.width * 0.65,
                                           alignment: .leading)
                                Text("Invert effective color range")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .frame(width: Geometry.size.width * 0.65,
                                           alignment: .leading)
                            }
                            Toggle("", isOn: Binding(
                                    get:
                                        {
                                            self.InvertRange
                                        },
                                set:
                                    {
                                        NewValue in
                                        self.InvertRange = NewValue
                                        Settings.SetBool(.ColorRangeInvertRange, NewValue)
                                        Updated.toggle()
                                    }
                            ))
                            .frame(width: Geometry.size.width * 0.2,
                                   alignment: .leading)
                        }
                        .padding([.leading, .trailing])
                        #else
                        SingleSettingViewToggle(Key: .ColorRangeInvertRange,
                                                Title: "Invert",
                                                SubTitle: "Invert effective range",
                                                ToggleValue: Settings.GetBool(.ColorRangeInvertRange),
                                                Updated: $Updated)
                            .padding([.leading, .trailing])
                            .padding(.bottom, 40)
                            .onChange(of: Updated)
                            {
                                NewValue in
                                print("Invert changed")
                            }
                        #endif
                       
                        Divider()
                            .background(Color.black)
                    }
                    
                    Group
                    {
                        VStack(alignment: .leading)
                        {
                            Text("Out of Range Colors")
                                .font(.headline)
                                .frame(width: Geometry.size.width * 0.8,
                                       alignment: .leading)
                            Text("Action to take with colors that do not fall into the included range.")
                                .font(.subheadline)
                                .lineLimit(3)
                                .fixedSize(horizontal: false, vertical: true)
                                .foregroundColor(.gray)
                                .frame(width: Geometry.size.width * 0.8,
                                       alignment: .leading)
                            Picker(ActionNames[$OutOfRangeAction.wrappedValue], selection: Binding(
                                get:
                                    {
                                        self.OutOfRangeAction
                                    },
                                set:
                                    {
                                        NewValue in
                                        self.OutOfRangeAction = NewValue
                                        Settings.SetInt(.ColorRangeOutOfRangeAction, self.OutOfRangeAction)
                                        Updated.toggle()
                                    }
                            )) {
                                Text("Mean grayscale").tag(0)
                                Text("Greatest grayscale").tag(1)
                                Text("Least grayscale").tag(2)
                                Text("Invert hue").tag(3)
                                Text("Invert brightness").tag(4)
                                Text("Reduce brightness").tag(5)
                                Text("Reduce saturation").tag(6)
                                Text("Use specified color").tag(7)
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: Geometry.size.width * 0.8,
                                   alignment: .leading)
                        }
                        .padding([.leading, .trailing])
                        
                        SingleSettingViewColor(Key: .ColorRangeOutOfRangeColor,
                                               Title: "Color",
                                               SubTitle: "The color to use for colors outside of the range.",
                                               ColorValue: Color(Settings.GetColor(.ColorRangeOutOfRangeColor, UIColor.red)),
                                               Updated: $Updated)
                            .disabled(OutOfRangeAction != 7)
                            .padding([.leading, .trailing])
                            .padding(.bottom, 50)
                        
                        Divider()
                            .background(Color.black)
                    }
                    
                    SampleImage(UICommand: $ButtonCommand,
                                Filter: .ColorRange,
                                Updated: $Updated.wrappedValue)
                        .frame(width: 300,
                               height: 300,
                               alignment: .center)
                }
            }
        }
        .onReceive(Changed.$ChangedFilter, perform:
                    {
                        Value in
                        Updated.toggle()
                    })
    }
}

struct ColorRangeFilter_Preiew: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        ColorRangeFilter_View(ButtonCommand: $NotUsed)
            .environmentObject(ChangedSettings())
    }
}
