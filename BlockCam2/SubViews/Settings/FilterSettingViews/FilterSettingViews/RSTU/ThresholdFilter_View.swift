//
//  ThresholdFilter_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/12/21.
//
/*
import SwiftUI

struct ThresholdFilter_View: View
{
    @Binding var ButtonCommand: String
    @EnvironmentObject var Changed: ChangedSettings
    @State var Updated: Bool = false
    @State var LowColor: Color = Color(Settings.GetColor(.ThresholdLowColor) ?? UIColor.white)
    @State var HighColor: Color = Color(Settings.GetColor(.ThresholdHighColor) ?? UIColor.black)
    @State var InputChannel: Int = Settings.GetInt(.ThresholdInputChannel)
    @State var ThresholdValue: Double = Settings.GetDouble(.ThresholdValue,
                                                           Settings.SettingDefaults[.ThresholdValue] as! Double).RoundedTo(2)
    @State var ThresholdValueString: String = "\(Settings.GetDouble(.ThresholdValue, Settings.SettingDefaults[.ThresholdValue] as! Double).RoundedTo(2))"
    @State var ApplyIfGreater: Bool = Settings.GetBool(.ThresholdApplyIfGreater)
    
    var body: some View
    {
        GeometryReader
        {
            Geometry in
            ScrollView
            {
                #if false
                HStack
                {
                    VStack(alignment: .leading)
                    {
                        Text("Threshold")
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                        Text("Value that determines the threshold between colors")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                    }
                    .padding()
                    Spacer()
                    VStack
                    {
                        Slider(value: Binding(
                            get:
                                {
                                    self.ThresholdValue
                                },
                            set:
                                {
                                    (NewValue) in
                                    //self.ThresholdValue = NewValue.RoundedTo(2)
                                    //self.ThresholdValueString = "\(self.ThresholdValue)"
                                    //Settings.SetDouble(.ThresholdValue, self.ThresholdValue)
                                    //self.Updated.toggle()
                                }
                        ), in: 0.0 ... 1.0
                        )
                        TextField("0", text: $ThresholdValueString,
                                  onCommit:
                                    {
                                        if let Actual = Double(self.ThresholdValueString)?.RoundedTo(2)
                                        {
                                            //Settings.SetDouble(.ThresholdValue, Actual)
                                            //self.ThresholdValue = Actual
                                            //Updated.toggle()
                                        }
                                    })
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.custom("Avenir-Black", size: 18.0))
                            .keyboardType(.numbersAndPunctuation)
                    }
                    .padding()
                }
                
                Spacer()
                
                HStack
                {
                    Text("Apply threshold if greater")
                        .frame(width: Geometry.size.width * 0.5,
                               alignment: .leading)
                    Toggle(isOn: self.$ApplyIfGreater)
                    {
                    }
                    .frame(width: Geometry.size.width * 0.5,
                           alignment: .trailing)
                    .onReceive([self.$ApplyIfGreater].publisher.first())
                    {
                        Value in
                        Settings.SetBool(.ThresholdApplyIfGreater, Value.wrappedValue)
                        Updated.toggle()
                    }
                    .padding()
                }
                #endif
                HStack
                {
                    VStack(alignment: .leading)
                    {
                        Text("High Color")
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                        Text("The color to apply if the channel is over the threshold.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                    }
                    .padding()
                    Spacer()
                    ColorPicker("", selection: $HighColor)
                        .onChange(of: HighColor)
                        {
                            _ in
                            Settings.SetColor(.ThresholdHighColor, UIColor(HighColor))
                            Updated.toggle()
                        }
                        .padding()
                }
                .padding()
                
                HStack
                {
                    VStack(alignment: .leading)
                    {
                        Text("Low Color")
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                        Text("The color to apply if the channel is under the threshold.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: Geometry.size.width * 0.5,
                                   alignment: .leading)
                    }
                    .padding()
                    Spacer()
                    ColorPicker("", selection: $LowColor)
                        .onChange(of: LowColor)
                        {
                            _ in
                            Settings.SetColor(.ThresholdLowColor, UIColor(LowColor))
                            Updated.toggle()
                        }
                        .frame(width: Geometry.size.width * 0.5,
                               alignment: .trailing)
                        .padding()
                }
                
                Spacer()
                /*
                SampleImage(UICommand: $ButtonCommand,
                            Filter: .Threshold,
                            Updated: $Updated.wrappedValue)
                    .frame(width: 300, height: 300, alignment: .center)
 */
            }
        }
        .onReceive(Changed.$ChangedFilter, perform:
                    {
                        Value in
                        if Value == BuiltInFilters.ColorMap.rawValue
                        {
                            LowColor = Color(Settings.GetColor(.ThresholdLowColor) ?? UIColor.white)
                            HighColor = Color(Settings.GetColor(.ThresholdHighColor) ?? UIColor.black)
                            InputChannel = Settings.GetInt(.ThresholdInputChannel)
                            ThresholdValue = Settings.GetDouble(.ThresholdValue,
                                                                                   Settings.SettingDefaults[.ThresholdValue] as! Double)
                            ApplyIfGreater = Settings.GetBool(.ThresholdApplyIfGreater)
                            Updated.toggle()
                        }
                    })
    }
}

struct ThresholdFilter_View_Previews: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        ThresholdFilter_View(ButtonCommand: $NotUsed)
            .environmentObject(ChangedSettings())
    }
}
*/
