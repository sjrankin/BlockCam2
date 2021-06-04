//
//  Test_GridControlView.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 6/4/21.
//

import SwiftUI

struct Test_GridControlView: View
{
    @State var BValues: [Bool] = [true, false, true, false]
    
    var body: some View
    {
        GeometryReader
        {
            Geometry in
            GridStackView(GridRows: 4, GridColumns: 3)
            {
                Row, Column in
                switch Column
                {
                    case 0:
                    Text("\(Row)")
                    .frame(width: (Geometry.size.width * 0.85) * 0.33)
                    .background(Color(UIColor.systemTeal))
                        
                    case 1:
                        HStack
                        {
                            Toggle("", isOn: Binding(
                                get:
                                    {
                                        self.BValues[Row]
                                    },
                                set:
                                    {
                                        NewValue in
                                        BValues[Row] = NewValue
                                    }
                            ))
                            .background(Color(UIColor.systemYellow))
                        }
                        .frame(width: (Geometry.size.width * 0.85) * 0.34,
                               alignment: .center)
                        
                    case 2:
                        Text("\(Column * Row)")
                            .frame(width: (Geometry.size.width * 0.85) * 0.33)
                            .background(Color(UIColor.systemGreen))
                    default:
                        Text("")
                }
            }
            .padding([.top, .leading, .trailing])
        }
    }
}

struct Test_GridControlView_Previews: PreviewProvider
{
    static var previews: some View
    {
        Test_GridControlView()
    }
}
