//
//  ArithmeticSimpleFilter_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 6/4/21.
//

import SwiftUI

struct ArithmeticSimpleFilter_View: View
{
    @EnvironmentObject var Changed: ChangedSettings
    @Binding var ButtonCommand: String
    @State var Updated: Bool = false
    @State var ClampResults: Bool = Settings.GetBool(.SimpleMathClamp)
    @State var AOp: Int = Settings.GetInt(.SimpleMathOperation)
    var ChannelNames = ["Red Channel", "Green Channel", "Blue Channel", "Alpha Channel"]
    @State var EnabledChannels =
        [
            Settings.GetBool(.SimpleMathEnableRed),
            Settings.GetBool(.SimpleMathEnableGreen),
            Settings.GetBool(.SimpleMathEnableBlue),
            Settings.GetBool(.SimpleMathEnableAlpha)
        ]
    @State var ChannelStrings =
        [
            Settings.GetDouble(.SimpleMathRedConstant).NormalizedString(3),
            Settings.GetDouble(.SimpleMathGreenConstant).NormalizedString(3),
            Settings.GetDouble(.SimpleMathBlueConstant).NormalizedString(3),
            Settings.GetDouble(.SimpleMathAlphaConstant).NormalizedString(3),
        ]
    @State var r: Double = Settings.GetDouble(.SimpleMathRedConstant).Normalized
    @State var g: Double = Settings.GetDouble(.SimpleMathGreenConstant).Normalized
    @State var b: Double = Settings.GetDouble(.SimpleMathBlueConstant).Normalized
    @State var a: Double = Settings.GetDouble(.SimpleMathAlphaConstant).Normalized
    
    var body: some View
    {
        GeometryReader
        {
            Geometry in
            ScrollView
            {
                VStack(alignment: .leading)
                {
                    VStack(alignment: .leading)
                    {
                        Text("Operation")
                            .font(.headline)
                            .frame(width: Geometry.size.width * 0.8,
                                   alignment: .leading)
                        Text("Select the arithmetic operation to use.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(width: Geometry.size.width * 0.8,
                                   alignment: .leading)
                        Picker(selection: $AOp,
                               label: Text(""))
                        {
                            Text("NOP").tag(0)
                            Text("Add").tag(1)
                            Text("Subtract").tag(3)
                            Text("Mean").tag(5)
                            Text("Divide").tag(6)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: AOp)
                        {
                            Value in
                            switch Value
                            {
                                case 0:
                                    AOp = Value
                                    
                                case 1:
                                    AOp = Value
                                    
                                case 3:
                                    AOp = Value
                                    
                                case 5:
                                    AOp = Value
                                    
                                case 6:
                                    AOp = Value
                                    
                                default:
                                    AOp = 0
                            }
                            Settings.SetInt(.SimpleMathOperation, AOp)
                            Updated.toggle()
                        }
                    }
                    .padding([.leading, .trailing])
                    
                    Divider()
                        .background(Color.black)
                    
                    VStack(alignment: .leading)
                    {
                        Group
                        {
                            Text("Channels")
                                .font(.headline)
                                .frame(width: Geometry.size.width * 0.8,
                                       alignment: .leading)
                            Text("Select the channels and constants for each channel.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(width: Geometry.size.width * 0.8,
                                       alignment: .leading)
                        }
                        
                        GridStackView(GridRows: 3, GridColumns: 3)
                        {
                            Row, Column in
                            switch Column
                            {
                                case 0:
                                    Text(ChannelNames[Row])
                                        .frame(width: (Geometry.size.width * 0.85) * 0.4,
                                               alignment: .leading)
                                case 1:
                                    Toggle("", isOn: Binding(
                                        get:
                                            {
                                                self.EnabledChannels[Row]
                                            },
                                        set:
                                            {
                                                NewValue in
                                                EnabledChannels[Row] = NewValue
                                                switch Row
                                                {
                                                    case 0:
                                                        Settings.SetBool(.SimpleMathEnableRed, NewValue)
                                                        
                                                    case 1:
                                                        Settings.SetBool(.SimpleMathEnableGreen, NewValue)
                                                        
                                                    case 2:
                                                        Settings.SetBool(.SimpleMathEnableBlue, NewValue)
                                                        
                                                    case 3:
                                                        Settings.SetBool(.SimpleMathEnableAlpha, NewValue)
                                                        
                                                    default:
                                                        break
                                                }
                                                Updated.toggle()
                                            }
                                    ))
                                    .frame(width: (Geometry.size.width * 0.85) * 0.3,
                                           alignment: .center)
                                    
                                case 2:
                                    #if false
                                    NumericTextField<Double>(Title: "", Value: $ChannelStrings[Row],
                                                             Formatter: NumberFormatter(),
                                                             KeyboardType: .numbersAndPunctuation)
                                    #else
                                    HStack
                                    {
                                    TextField("", text: $ChannelStrings[Row])
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .font(.custom("Avenir-Black", size: 18.0))
                                        .frame(width: (Geometry.size.width * 0.85) * 0.3)
                                        .keyboardType(.numbersAndPunctuation)
                                        .onChange(of: ChannelStrings[Row])
                                        {
                                            NewValue in
                                            var Constant = Double(NewValue) ?? 0.0
                                            Constant = Constant.Normalized(3)
                                            ChannelStrings[Row] = "\(Constant)"
                                            switch Row
                                            {
                                                case 0:
                                                    print("New red value=\(Constant)")
                                                    Settings.SetDouble(.SimpleMathRedConstant, Constant)
                                                    
                                                case 1:
                                                    print("New green value=\(Constant)")
                                                    Settings.SetDouble(.SimpleMathGreenConstant, Constant)
                                                    
                                                case 2:
                                                    print("New blue value=\(Constant)")
                                                    Settings.SetDouble(.SimpleMathBlueConstant, Constant)
                                                    
                                                case 3:
                                                    print("New alpha value=\(Constant)")
                                                    Settings.SetDouble(.SimpleMathAlphaConstant, Constant)
                                                    
                                                default:
                                                    break
                                            }
                                            Updated.toggle()
                                        }
                                    }
                                    #endif
                                    
                                default:
                                    Text("")
                            }
                        }
                    }
                    .padding([.leading, .trailing])
                    
                    Divider()
                        .background(Color.black)
                    
                    HStack
                    {
                        VStack(alignment: .leading)
                        {
                            Text("Clamp")
                                .font(.headline)
                                .frame(width: Geometry.size.width * 0.6,
                                       alignment: .leading)
                            Text("Clamp kernel results to normal range.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(width: Geometry.size.width * 0.6,
                                       alignment: .leading)
                        }
                        Toggle("", isOn: Binding(
                            get:
                                {
                                    self.ClampResults
                                },
                            set:
                                {
                                    NewValue in
                                    self.ClampResults = NewValue
                                    Settings.SetBool(.SimpleMathClamp, NewValue)
                                    Updated.toggle()
                                }
                        ))
                    }
                    .padding([.leading, .trailing])
                    
                    Divider()
                        .background(Color.black)
                }
                
                SampleImage(UICommand: $ButtonCommand,
                            Filter: .SimpleArithmetic,
                            Updated: $Updated.wrappedValue)
                    .frame(width: 300, height: 300, alignment: .center)
            }
        }
        .onReceive(Changed.$ChangedFilter, perform:
                    {
                        Value in
                        if Value == BuiltInFilters.SimpleArithmetic.rawValue
                        {
                            AOp = Settings.GetInt(.SimpleMathOperation)
                            ClampResults = Settings.GetBool(.SimpleMathClamp)
                            EnabledChannels[0] = Settings.GetBool(.SimpleMathEnableRed)
                            EnabledChannels[1] = Settings.GetBool(.SimpleMathEnableGreen)
                            EnabledChannels[2] = Settings.GetBool(.SimpleMathEnableBlue)
                            EnabledChannels[3] = Settings.GetBool(.SimpleMathEnableAlpha)
                            ChannelStrings[0] = Settings.GetDouble(.SimpleMathRedConstant).NormalizedString(3)
                            ChannelStrings[1] = Settings.GetDouble(.SimpleMathGreenConstant).NormalizedString(3)
                            ChannelStrings[2] = Settings.GetDouble(.SimpleMathBlueConstant).NormalizedString(3)
                            ChannelStrings[3] = Settings.GetDouble(.SimpleMathAlphaConstant).NormalizedString(3)
                            Updated.toggle()
                        }
                    })
    }
}

struct ArithmeticSimpleFilter_View_Previews: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        ArithmeticSimpleFilter_View(ButtonCommand: $NotUsed)
            .environmentObject(ChangedSettings())
    }
}

