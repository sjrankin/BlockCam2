//
//  GrayscaleMetalFilter_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/15/21.
//

import Foundation
import SwiftUI

struct GrayscaleMetalFilter_View: View
{
    @Binding var ButtonCommand: String
    @EnvironmentObject var Changed: ChangedSettings
    @State var Updated: Bool = false
    @State var BWOperation = Settings.GetInt(.GrayscaleMetalCommand)
    @State var RedValue = Settings.GetDouble(.GrayscaleRedMultiplier).RoundedTo(2)
    @State var RedString = "\(Settings.GetDouble(.GrayscaleRedMultiplier).RoundedTo(2))"
    @State var GreenValue = Settings.GetDouble(.GrayscaleGreenMultiplier).RoundedTo(2)
    @State var GreenString = "\(Settings.GetDouble(.GrayscaleGreenMultiplier).RoundedTo(2))"
    @State var BlueValue = Settings.GetDouble(.GrayscaleBlueMultiplier).RoundedTo(2)
    @State var BlueString = "\(Settings.GetDouble(.GrayscaleBlueMultiplier).RoundedTo(2))"
    
    var body: some View
    {
        GeometryReader
        {
            Geometry in
            ScrollView
            {
                HStack
                {
                    VStack(alignment: .leading)
                    {
                        Text("Method")
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                        Text("Select the method to use to convert the image to grayscale.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                    }
                    .padding()

                    
                    Spacer()
                    Picker(selection: $BWOperation,
                           label: Text(GrayscaleAdjust.GetOperationName(Index: BWOperation)))
                    {
                        Group
                        {
                            Text("Mean").tag(0)
                            Text("Luminance").tag(1)
                            Text("Desaturation").tag(2)
                            Text("BT.601").tag(3)
                            Text("BT.709").tag(4)
                            Text("Max Value").tag(5)
                            Text("Min Value").tag(6)
                            Text("Red").tag(7)
                            Text("Green").tag(8)
                            Text("Blue").tag(9)
                        }
                        Group
                        {
                            Text("Cyan").tag(10)
                            Text("Magenta").tag(11)
                            Text("Yellow").tag(12)
                            Text("CMYK Cyan").tag(13)
                            Text("CMYK Magenta").tag(14)
                            Text("CMYK Yellow").tag(15)
                            Text("CMYK Black").tag(16)
                            Text("Hue").tag(17)
                            Text("Saturation").tag(18)
                            Text("Brightness").tag(19)
                        }
                        Group
                        {
                            Text("Mean CMYK").tag(20)
                            Text("Mean HSB").tag(21)
                            Text("User").tag(22)
                        }
                    }
                    .onChange(of: BWOperation)
                    {
                        Value in
                        Settings.SetInt(.GrayscaleMetalCommand, Value)
                        Updated.toggle()
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding([.leading, .trailing])
                
                Divider()
                    .background(Color.black)

                HStack
                {
                    VStack(alignment: .leading)
                    {
                        Text("Red Channel")
                            .frame(width: Geometry.size.width * 0.4,
                                   alignment: .leading)
                        Text("Value to multiply against the red channel. For User method.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: Geometry.size.width * 0.4,
                                   alignment: .leading)
                    }
                    .padding()
                    Spacer()
                    VStack
                    {
                        TextField("", text: $RedString,
                                  onCommit:
                                    {
                                        if let Actual = Double(self.RedString)
                                        {
                                            RedValue = Actual.RoundedTo(2)
                                            Settings.SetDouble(.GrayscaleRedMultiplier, RedValue)
                                            Updated.toggle()
                                        }
                                    })
                            .frame(width: Geometry.size.width * 0.35)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.custom("Avenir-Black", size: 18.0))
                            .keyboardType(.numbersAndPunctuation)
                        
                        Slider(value: Binding(
                                get:
                                    {
                                        self.RedValue
                                    },
                                set:
                                    {
                                        (NewValue) in
                                        self.RedValue = NewValue.RoundedTo(3)
                                        RedString = "\(self.RedValue)"
                                        Settings.SetDouble(.GrayscaleRedMultiplier, self.RedValue)
                                        Updated.toggle()
                                    }), in: 0.0 ... 1.0)
                            .frame(width: Geometry.size.width * 0.35)
                            .padding()
                        
                    }
                }
                .padding([.leading, .trailing])
                
                Divider()
                    .background(Color.black)

                HStack
                {
                    VStack(alignment: .leading)
                    {
                        Text("Green Channel")
                            .frame(width: Geometry.size.width * 0.4,
                                   alignment: .leading)
                        Text("Value to multiply against the green channel. For User method.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: Geometry.size.width * 0.4,
                                   alignment: .leading)
                    }
                    .padding()
                    Spacer()
                    VStack
                    {
                        TextField("", text: $GreenString,
                                  onCommit:
                                    {
                                        if let Actual = Double(self.GreenString)
                                        {
                                            GreenValue = Actual.RoundedTo(2)
                                            Settings.SetDouble(.GrayscaleGreenMultiplier, GreenValue)
                                            Updated.toggle()
                                        }
                                    })
                            .frame(width: Geometry.size.width * 0.35)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.custom("Avenir-Black", size: 18.0))
                            .keyboardType(.numbersAndPunctuation)
                        
                        Slider(value: Binding(
                                get:
                                    {
                                        self.GreenValue
                                    },
                                set:
                                    {
                                        (NewValue) in
                                        self.GreenValue = NewValue.RoundedTo(3)
                                        GreenString = "\(self.GreenValue)"
                                        Settings.SetDouble(.GrayscaleGreenMultiplier, self.GreenValue)
                                        Updated.toggle()
                                    }), in: 0.0 ... 1.0)
                            .frame(width: Geometry.size.width * 0.35)
                            .padding()
                        
                    }
                }
                .padding([.leading, .trailing])
                
                Divider()
                    .background(Color.black)

                HStack
                {
                    VStack(alignment: .leading)
                    {
                        Text("Blue Channel")
                            .frame(width: Geometry.size.width * 0.4,
                                   alignment: .leading)
                        Text("Value to multiply against the blue channel. For User method.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: Geometry.size.width * 0.4,
                                   alignment: .leading)
                    }
                    .padding()
                    Spacer()
                    VStack
                    {
                        TextField("", text: $BlueString,
                                  onCommit:
                                    {
                                        if let Actual = Double(self.BlueString)
                                        {
                                            BlueValue = Actual.RoundedTo(2)
                                            Settings.SetDouble(.GrayscaleBlueMultiplier, BlueValue)
                                            Updated.toggle()
                                        }
                                    })
                            .frame(width: Geometry.size.width * 0.35)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.custom("Avenir-Black", size: 18.0))
                            .keyboardType(.numbersAndPunctuation)
                        
                        Slider(value: Binding(
                                get:
                                    {
                                        self.BlueValue
                                    },
                                set:
                                    {
                                        (NewValue) in
                                        self.RedValue = NewValue.RoundedTo(3)
                                        BlueString = "\(self.BlueValue)"
                                        Settings.SetDouble(.GrayscaleBlueMultiplier, self.BlueValue)
                                        Updated.toggle()
                                    }), in: 0.0 ... 1.0)
                            .frame(width: Geometry.size.width * 0.35)
                            .padding()
                        
                    }
                }
                .padding([.leading, .trailing])
                
                Spacer()
                Divider()
                    .background(Color.black)

                SampleImage(UICommand: $ButtonCommand,
                            Filter: .MetalGrayscale,
                            Updated: $Updated.wrappedValue)
                    .frame(width: 300, height: 300, alignment: .center)
            }
        }
        .onReceive(Changed.$ChangedFilter, perform:
                    {
                        Value in
                        Updated.toggle()
                    })
    }
}

struct GrayscaleMetalFilter_Preview: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        GrayscaleMetalFilter_View(ButtonCommand: $NotUsed)
            .environmentObject(ChangedSettings())
    }
}
