//
//  MatrixCellView.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/14/21.
//

import SwiftUI

struct MatrixCellView: View
{
//    @Binding var CellValue: Double
    @Binding var CellValue: String
    @State var CellWidth: CGFloat = 20.0
    @State var CellX: Int
    @State var CellY: Int
    @State var Enabled: Bool
    @State var Updated: Bool
    let CellFormatter: NumberFormatter =
        {
            let Formatter = NumberFormatter()
            Formatter.numberStyle = .decimal
            return Formatter
        }()
    
    var body: some View
    {
        TextField("", text: Binding<String>(
                    get:
                        {
                        self.CellValue
                    },
                    set:
                        {
                        self.CellValue = $0
                    }))
            .frame(width: CellWidth)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .font(.custom("Avenir-Black", size: 15.0))
            .keyboardType(.numberPad)
            .disabled(!$Enabled.wrappedValue)
            .foregroundColor($Enabled.wrappedValue ? .black : .gray)
            .border(Updated ? Color.yellow : Color.black, width: 1)
    }
}

struct MatrixCellView_Previews: PreviewProvider
{
    @State static var Value: String = "0.55"
    @State static var X: Int = 0
    @State static var Y: Int = 0
    @State static var IsEnabled: Bool = true
    @State static var Updated: Bool = false
    
    static var previews: some View
    {
        MatrixCellView(CellValue: $Value,
                       CellWidth: 50,
                       CellX: X,
                       CellY: Y,
                       Enabled: IsEnabled,
                       Updated: Updated)
    }
}
