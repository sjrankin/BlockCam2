//
//  ArithmeticMultiframeFilter_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 6/5/21.
//

import SwiftUI

struct ArithmeticMultiframeFilter_View: View
{
    @EnvironmentObject var Changed: ChangedSettings
    @Binding var ButtonCommand: String
    @State var Updated: Bool = false
    @State var AOp: Int = Settings.GetInt(.MFMathOperation)
    @State var UseRed: Bool = Settings.GetBool(.MFApplyToRed)
    @State var UseGreen: Bool = Settings.GetBool(.MFApplyToGreen)
    @State var UseBlue: Bool = Settings.GetBool(.MFApplyToBlue)
    @State var UseAlpha: Bool = Settings.GetBool(.MFApplyToAlpha)
    
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
                            Text("Add").tag(2)
                            Text("Subtract").tag(4)
                            Text("Mean").tag(7)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: AOp)
                        {
                            Value in
                            switch Value
                            {
                                case 0:
                                    AOp = Value
                                    
                                case 2:
                                    AOp = Value
                                    
                                case 4:
                                    AOp = Value
                                    
                                case 7:
                                    AOp = Value
                                    
                                default:
                                    AOp = 0
                            }
                            Settings.SetInt(.MFMathOperation, AOp)
                            Updated.toggle()
                        }
                    }
                    .padding([.leading, .trailing])
                    
                    Divider()
                        .background(Color.black)
                    
                    VStack(alignment: .leading)
                    {
                        Text("Channels")
                            .font(.headline)
                            .frame(width: Geometry.size.width * 0.8,
                                   alignment: .leading)
                        Text("Select the channels to apply the operation to.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: Geometry.size.width * 0.8,
                                   alignment: .leading)
                        VStack(alignment: .leading)
                        {
                            HStack
                            {
                                Text("Red Channel")
                                    .foregroundColor(.black)
                                    .frame(width: Geometry.size.width * 0.5,
                                           alignment: .leading)
                                Spacer()
                                Toggle("", isOn: Binding(
                                    get:
                                        {
                                            self.UseRed
                                        },
                                    set:
                                        {
                                            NewValue in
                                            self.UseRed = NewValue
                                            Settings.SetBool(.MFApplyToRed, NewValue)
                                            Updated.toggle()
                                        }
                                ))
                                .frame(width: Geometry.size.width * 0.3)
                            }
                            .frame(width: Geometry.size.width * 0.9,
                                   alignment: .leading)
                            HStack
                            {
                                Text("Green Channel")
                                    .foregroundColor(.black)
                                    .frame(width: Geometry.size.width * 0.5,
                                           alignment: .leading)
                                Spacer()
                                Toggle("", isOn: Binding(
                                    get:
                                        {
                                            self.UseGreen
                                        },
                                    set:
                                        {
                                            NewValue in
                                            self.UseGreen = NewValue
                                            Settings.SetBool(.MFApplyToGreen, NewValue)
                                            Updated.toggle()
                                        }
                                ))
                                .frame(width: Geometry.size.width * 0.3)
                            }
                            .frame(width: Geometry.size.width * 0.9,
                                   alignment: .leading)
                            HStack
                            {
                                Text("Blue Channel")
                                    .foregroundColor(.black)
                                    .frame(width: Geometry.size.width * 0.5,
                                           alignment: .leading)
                                Spacer()
                                Toggle("", isOn: Binding(
                                    get:
                                        {
                                            self.UseBlue
                                        },
                                    set:
                                        {
                                            NewValue in
                                            self.UseBlue = NewValue
                                            Settings.SetBool(.MFApplyToBlue, NewValue)
                                            Updated.toggle()
                                        }
                                ))
                                .frame(width: Geometry.size.width * 0.3)
                            }
                            .frame(width: Geometry.size.width * 0.9,
                                   alignment: .leading)
                        }
                    }
                    .padding([.leading, .trailing])
                    
                    Divider()
                        .background(Color.black)
                    
                    VStack(alignment: .leading)
                    {
                    Text("Note")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                        .frame(width: Geometry.size.width * 0.9,
                               alignment: .leading)
                        Text("All images must have the same dimensions in order for this filter to work properly.")
                            .font(.subheadline)
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(width: Geometry.size.width * 0.9,
                                   alignment: .leading)
                    }
                    .padding([.leading, .trailing])
                    
                    Divider()
                        .background(Color.black)
                }
            }
        }
    }
}

struct ArithmeticMultiframeFilter_Previews: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        ArithmeticMultiframeFilter_View(ButtonCommand: $NotUsed)
            .environmentObject(ChangedSettings())
    }
}
