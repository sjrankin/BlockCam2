//
//  ConvolutionFilter_View.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/15/21.
//

import Foundation
import SwiftUI

struct ConvolutionFilter_View: View
{
    @EnvironmentObject var Changed: ChangedSettings
    @Binding var ButtonCommand: String
    @State var Updated: Bool = false
    var CellWidth: CGFloat = 60
    
    @State var Kernel: [[String]] = Settings.GetMatrixAsString(.ConvolutionKernel)
    @State var Bias: Double = Settings.GetDouble(.ConvolutionBias, 0.0).RoundedTo(3)
    @State var BiasString: String = "\(Settings.GetDouble(.ConvolutionBias, 0.0).RoundedTo(3))"
    @State var KernelWidth: Int = Settings.GetInt(.ConvolutionWidth, IfZero: 1)
    @State var KernelHeight: Int = Settings.GetInt(.ConvolutionHeight, IfZero: 1)
    @State var Predefined: Int = Settings.GetInt(.ConvolutionPredefinedKernel)
    
    var body: some View
    {
        GeometryReader
        {
            Geometry in
            ScrollView
            {
                VStack(spacing: 5)
                {
                    HStack
                    {
                        VStack(alignment: .leading)
                        {
                            Text("Bias")
                                .frame(width: Geometry.size.width * 0.4,
                                       alignment: .leading)
                            Text("Value to add to pixels after convolution.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(width: Geometry.size.width * 0.4,
                                       alignment: .leading)
                        }
                        .padding()
                        Spacer()
                        VStack
                        {
                            TextField("", text: $BiasString,
                                      onCommit:
                                        {
                                            if let Actual = Double(self.BiasString)
                                            {
                                                Bias = Actual.RoundedTo(3)
                                                Settings.SetDouble(.ConvolutionBias, Bias)
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
                                            self.Bias
                                        },
                                    set:
                                        {
                                            (NewValue) in
                                            self.Bias = NewValue.RoundedTo(3)
                                            BiasString = "\(self.Bias)"
                                            Settings.SetDouble(.ConvolutionBias, self.Bias)
                                            Updated.toggle()
                                        }), in: 0.0 ... 1.0)
                                .frame(width: Geometry.size.width * 0.35)
                                .padding()
                            
                        }
                    }
                    .padding([.top, .leading, .trailing])
                    
                    Divider().background(Color.black)
                    
                    HStack
                    {
                        VStack
                        {
                            Text("Kernel Width")
                                .frame(width: Geometry.size.width * 0.4,
                                       alignment: .leading)
                            Picker(selection: $KernelWidth, label: Text(""))
                            {
                                Text("1").tag(1)
                                Text("3").tag(3)
                                Text("5").tag(5)
                            }
                            .onChange(of: KernelWidth, perform:
                                        {
                                            Value in
                                            KernelWidth = Value
                                            print("New Width=\(KernelWidth)")
                                            Settings.SetInt(.ConvolutionWidth, Value)
                                            Updated.toggle()
                                        })
                            .pickerStyle(SegmentedPickerStyle())
                            .frame(width: Geometry.size.width * 0.4)
                        }
                        .padding()
                        VStack
                        {
                            Text("Kernel Height")
                                .frame(width: Geometry.size.width * 0.4,
                                       alignment: .leading)
                            Picker(selection: $KernelHeight, label: Text(""))
                            {
                                Text("1").tag(1)
                                Text("3").tag(3)
                                Text("5").tag(5)
                            }
                            .onChange(of: KernelHeight, perform:
                                        {
                                            Value in
                                            KernelHeight = Value
                                            print("New Height=\(KernelHeight)")
                                            Settings.SetInt(.ConvolutionHeight, Value)
                                            Updated.toggle()
                                        })
                            .pickerStyle(SegmentedPickerStyle())
                            .frame(width: Geometry.size.width * 0.4)
                        }
                        .padding()
                    }
                    
                    VStack
                    {
                        HStack
                        {
                            TextField("", text: Binding<String>(
                                        get:
                                            {
                                                self.Kernel[0][0]
                                            },
                                        set:
                                            {
                                                self.Kernel[0][0] = $0
                                            }))
                                .frame(width: CellWidth)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.custom("Avenir-Black", size: 15.0))
                                .keyboardType(.numberPad)
                                .disabled(false)
                                .foregroundColor(.black)
                            
                            TextField("", text: Binding<String>(
                                        get:
                                            {
                                                self.Kernel[0][1]
                                            },
                                        set:
                                            {
                                                self.Kernel[0][1] = $0
                                            }))
                                .frame(width: CellWidth)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.custom("Avenir-Black", size: 15.0))
                                .keyboardType(.numberPad)
                                .disabled(false)
                                .foregroundColor(KernelWidth > 1 ? .black : .gray)
                            
                            TextField("", text: Binding<String>(
                                        get:
                                            {
                                                self.Kernel[0][2]
                                            },
                                        set:
                                            {
                                                self.Kernel[0][2] = $0
                                            }))
                                .frame(width: CellWidth)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.custom("Avenir-Black", size: 15.0))
                                .keyboardType(.numberPad)
                                .disabled(false)
                                .foregroundColor(KernelWidth > 2 ? .black : .gray)
                            
                            TextField("", text: Binding<String>(
                                        get:
                                            {
                                                self.Kernel[0][3]
                                            },
                                        set:
                                            {
                                                self.Kernel[0][3] = $0
                                            }))
                                .frame(width: CellWidth)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.custom("Avenir-Black", size: 15.0))
                                .keyboardType(.numberPad)
                                .disabled(false)
                                .foregroundColor(KernelWidth > 3 ? .black : .gray)
                            
                            TextField("", text: Binding<String>(
                                        get:
                                            {
                                                self.Kernel[0][4]
                                            },
                                        set:
                                            {
                                                self.Kernel[0][4] = $0
                                            }))
                                .frame(width: CellWidth)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.custom("Avenir-Black", size: 15.0))
                                .keyboardType(.numberPad)
                                .disabled(false)
                                .foregroundColor(KernelWidth > 4 ? .black : .gray)
                        }
                        
                        HStack
                        {
                            TextField("", text: Binding<String>(
                                        get:
                                            {
                                                self.Kernel[1][0]
                                            },
                                        set:
                                            {
                                                self.Kernel[1][0] = $0
                                            }))
                                .frame(width: CellWidth)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.custom("Avenir-Black", size: 15.0))
                                .keyboardType(.numberPad)
                                .disabled(false)
                                .foregroundColor(KernelHeight > 1 ? .black : .gray)
                            
                            TextField("", text: Binding<String>(
                                        get:
                                            {
                                                self.Kernel[1][1]
                                            },
                                        set:
                                            {
                                                self.Kernel[1][1] = $0
                                            }))
                                .frame(width: CellWidth)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.custom("Avenir-Black", size: 15.0))
                                .keyboardType(.numberPad)
                                .disabled(false)
                                .foregroundColor(KernelWidth > 1 && KernelHeight > 1 ? .black : .gray)
                            
                            TextField("", text: Binding<String>(
                                        get:
                                            {
                                                self.Kernel[1][2]
                                            },
                                        set:
                                            {
                                                self.Kernel[1][2] = $0
                                            }))
                                .frame(width: CellWidth)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.custom("Avenir-Black", size: 15.0))
                                .keyboardType(.numberPad)
                                .disabled(false)
                                .foregroundColor(KernelWidth > 2 && KernelHeight > 1 ? .black : .gray)
                            
                            TextField("", text: Binding<String>(
                                        get:
                                            {
                                                self.Kernel[1][3]
                                            },
                                        set:
                                            {
                                                self.Kernel[1][3] = $0
                                            }))
                                .frame(width: CellWidth)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.custom("Avenir-Black", size: 15.0))
                                .keyboardType(.numberPad)
                                .disabled(false)
                                .foregroundColor(KernelWidth > 3 && KernelHeight > 1 ? .black : .gray)
                            
                            TextField("", text: Binding<String>(
                                        get:
                                            {
                                                self.Kernel[1][4]
                                            },
                                        set:
                                            {
                                                self.Kernel[1][4] = $0
                                            }))
                                .frame(width: CellWidth)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.custom("Avenir-Black", size: 15.0))
                                .keyboardType(.numberPad)
                                .disabled(false)
                                .foregroundColor(KernelWidth > 4 && KernelHeight > 1 ? .black : .gray)
                        }
                        
                        HStack
                        {
                            TextField("", text: Binding<String>(
                                        get:
                                            {
                                                self.Kernel[2][0]
                                            },
                                        set:
                                            {
                                                self.Kernel[2][0] = $0
                                            }))
                                .frame(width: CellWidth)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.custom("Avenir-Black", size: 15.0))
                                .keyboardType(.numberPad)
                                .disabled(false)
                                .foregroundColor(KernelHeight > 2 && KernelHeight > 2 ? .black : .gray)
                            
                            TextField("", text: Binding<String>(
                                        get:
                                            {
                                                self.Kernel[2][1]
                                            },
                                        set:
                                            {
                                                self.Kernel[2][1] = $0
                                            }))
                                .frame(width: CellWidth)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.custom("Avenir-Black", size: 15.0))
                                .keyboardType(.numberPad)
                                .disabled(false)
                                .foregroundColor(KernelWidth > 1 && KernelHeight > 2 ? .black : .gray)
                            
                            TextField("", text: Binding<String>(
                                        get:
                                            {
                                                self.Kernel[2][2]
                                            },
                                        set:
                                            {
                                                self.Kernel[2][2] = $0
                                            }))
                                .frame(width: CellWidth)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.custom("Avenir-Black", size: 15.0))
                                .keyboardType(.numberPad)
                                .disabled(false)
                                .foregroundColor(KernelWidth > 2 && KernelHeight > 2 ? .black : .gray)
                            
                            TextField("", text: Binding<String>(
                                        get:
                                            {
                                                self.Kernel[2][3]
                                            },
                                        set:
                                            {
                                                self.Kernel[2][3] = $0
                                            }))
                                .frame(width: CellWidth)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.custom("Avenir-Black", size: 15.0))
                                .keyboardType(.numberPad)
                                .disabled(false)
                                .foregroundColor(KernelWidth > 3 && KernelHeight > 2 ? .black : .gray)
                            
                            TextField("", text: Binding<String>(
                                        get:
                                            {
                                                self.Kernel[2][4]
                                            },
                                        set:
                                            {
                                                self.Kernel[2][4] = $0
                                            }))
                                .frame(width: CellWidth)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.custom("Avenir-Black", size: 15.0))
                                .keyboardType(.numberPad)
                                .disabled(false)
                                .foregroundColor(KernelWidth > 4 && KernelHeight > 2 ? .black : .gray)
                        }
                        
                        HStack
                        {
                            TextField("", text: Binding<String>(
                                        get:
                                            {
                                                self.Kernel[3][0]
                                            },
                                        set:
                                            {
                                                self.Kernel[3][0] = $0
                                            }))
                                .frame(width: CellWidth)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.custom("Avenir-Black", size: 15.0))
                                .keyboardType(.numberPad)
                                .disabled(false)
                                .foregroundColor(KernelHeight > 2 && KernelHeight > 3 ? .black : .gray)
                            
                            TextField("", text: Binding<String>(
                                        get:
                                            {
                                                self.Kernel[3][1]
                                            },
                                        set:
                                            {
                                                self.Kernel[3][1] = $0
                                            }))
                                .frame(width: CellWidth)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.custom("Avenir-Black", size: 15.0))
                                .keyboardType(.numberPad)
                                .disabled(false)
                                .foregroundColor(KernelWidth > 1 && KernelHeight > 3 ? .black : .gray)
                            
                            TextField("", text: Binding<String>(
                                        get:
                                            {
                                                self.Kernel[3][2]
                                            },
                                        set:
                                            {
                                                self.Kernel[3][2] = $0
                                            }))
                                .frame(width: CellWidth)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.custom("Avenir-Black", size: 15.0))
                                .keyboardType(.numberPad)
                                .disabled(false)
                                .foregroundColor(KernelWidth > 2 && KernelHeight > 3 ? .black : .gray)
                            
                            TextField("", text: Binding<String>(
                                        get:
                                            {
                                                self.Kernel[3][3]
                                            },
                                        set:
                                            {
                                                self.Kernel[3][3] = $0
                                            }))
                                .frame(width: CellWidth)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.custom("Avenir-Black", size: 15.0))
                                .keyboardType(.numberPad)
                                .disabled(false)
                                .foregroundColor(KernelWidth > 3 && KernelHeight > 3 ? .black : .gray)
                            
                            TextField("", text: Binding<String>(
                                        get:
                                            {
                                                self.Kernel[3][4]
                                            },
                                        set:
                                            {
                                                self.Kernel[3][4] = $0
                                            }))
                                .frame(width: CellWidth)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.custom("Avenir-Black", size: 15.0))
                                .keyboardType(.numberPad)
                                .disabled(false)
                                .foregroundColor(KernelWidth > 4 && KernelHeight > 3 ? .black : .gray)
                        }
                        
                        HStack
                        {
                            TextField("", text: Binding<String>(
                                        get:
                                            {
                                                self.Kernel[4][0]
                                            },
                                        set:
                                            {
                                                self.Kernel[4][0] = $0
                                            }))
                                .frame(width: CellWidth)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.custom("Avenir-Black", size: 15.0))
                                .keyboardType(.numberPad)
                                .disabled(false)
                                .foregroundColor(KernelHeight > 2 && KernelHeight > 4 ? .black : .gray)
                            
                            TextField("", text: Binding<String>(
                                        get:
                                            {
                                                self.Kernel[4][1]
                                            },
                                        set:
                                            {
                                                self.Kernel[4][1] = $0
                                            }))
                                .frame(width: CellWidth)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.custom("Avenir-Black", size: 15.0))
                                .keyboardType(.numberPad)
                                .disabled(false)
                                .foregroundColor(KernelWidth > 1 && KernelHeight > 4 ? .black : .gray)
                            
                            TextField("", text: Binding<String>(
                                        get:
                                            {
                                                self.Kernel[4][2]
                                            },
                                        set:
                                            {
                                                self.Kernel[4][2] = $0
                                            }))
                                .frame(width: CellWidth)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.custom("Avenir-Black", size: 15.0))
                                .keyboardType(.numberPad)
                                .disabled(false)
                                .foregroundColor(KernelWidth > 2 && KernelHeight > 4 ? .black : .gray)
                            
                            TextField("", text: Binding<String>(
                                        get:
                                            {
                                                self.Kernel[4][3]
                                            },
                                        set:
                                            {
                                                self.Kernel[4][3] = $0
                                            }))
                                .frame(width: CellWidth)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.custom("Avenir-Black", size: 15.0))
                                .keyboardType(.numberPad)
                                .disabled(false)
                                .foregroundColor(KernelWidth > 3 && KernelHeight > 4 ? .black : .gray)
                            
                            TextField("", text: Binding<String>(
                                        get:
                                            {
                                                self.Kernel[4][4]
                                            },
                                        set:
                                            {
                                                self.Kernel[4][4] = $0
                                            }))
                                .frame(width: CellWidth)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.custom("Avenir-Black", size: 15.0))
                                .keyboardType(.numberPad)
                                .disabled(false)
                                .foregroundColor(KernelWidth > 4 && KernelHeight > 4 ? .black : .gray)
                        }
                        HStack
                        {
                            Picker(selection: $Predefined,
                                   label: Text(MPSConvolution.GetKernelName(Index: Predefined)))
                            {
                                Group
                                {
                                    Text("Custom").tag(0)
                                    Text("Identity").tag(1)
                                }
                                Group
                                {
                                    Text("Weak Edge Detection").tag(2)
                                    Text("Edge Detection").tag(3)
                                    Text("Strong Edge Detection").tag(4)
                                }
                                Group
                                {
                                    Text("Sharpen").tag(5)
                                    Text("Sharpen & Deblur").tag(6)
                                    Text("Box Blur").tag(7)
                                    Text("Roberts").tag(8)
                                    Text("Kirsch").tag(9)
                                    Text("Frei-Chen").tag(10)
                                    Text("Lagrangian").tag(11)
                                }
                            }
                            .onChange(of: Predefined)
                            {
                                Value in
                                Settings.SetInt(.ConvolutionPredefinedKernel, Value)
                                if Value > 0
                                {
                                    let RawKernel = MPSConvolution.GetPredefinedKernel(Index: Value)
                                    Kernel = Settings.ConvertToStringMatrix(RawKernel)
                                    Updated.toggle()
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            Spacer()
                            Button("Apply Kernel")
                            {
                                let Matrix = Settings.ConvertToDoubleMatrix(Kernel)
                                Settings.SetMatrix(.ConvolutionKernel, Matrix)
                                Updated.toggle()
                            }
                        }
                        .padding()
                    }
                    .padding(.top, -10)
                    .padding(.bottom)
                    
                    Divider().background(Color.black)
                    
                    SampleImage(UICommand: $ButtonCommand,
                                Filter: .Convolution,
                                Updated: $Updated.wrappedValue)
                        .frame(width: 300, height: 300, alignment: .center)
                }
            }
        }
        .onReceive(Changed.$ChangedFilter, perform:
                    {
                        Value in
                        if Value == BuiltInFilters.BumpDistortion.rawValue
                        {
                            Bias = Settings.GetDouble(.ConvolutionBias)
                            KernelWidth = Settings.GetInt(.ConvolutionWidth)
                            KernelHeight = Settings.GetInt(.ConvolutionHeight)
                            Kernel = Settings.GetMatrixAsString(.ConvolutionKernel)
                            Updated.toggle()
                        }
                    })
    }
}

struct ConvolutionFilterView_Previews: PreviewProvider
{
    @State static var NotUsed: String = ""
    
    static var previews: some View
    {
        ConvolutionFilter_View(ButtonCommand: $NotUsed)
            .environmentObject(ChangedSettings())
    }
}
