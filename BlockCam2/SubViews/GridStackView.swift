//
//  GridStackView.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 6/4/21.
//

import SwiftUI

//https://www.hackingwithswift.com/quick-start/swiftui/how-to-position-views-in-a-grid-using-lazyvgrid-and-lazyhgrid
struct GridStackView<Content: View>: View
{
    let Rows: Int
    let Columns: Int
    let Contents: (Int, Int) -> Content
 
    init(GridRows: Int, GridColumns: Int, @ViewBuilder content: @escaping (Int, Int) -> Content)
    {
        Rows = GridRows
        Columns = GridColumns
        Contents = content
    }
    
    var body: some View
    {
        VStack
        {
            ForEach(0 ..< Rows, id: \.self)
            {
                Row in
                HStack
                {
                    ForEach(0 ..< Columns, id: \.self)
                    {
                        Column in
                        Contents(Row, Column)
                    }
                }
            }
        }
    }
}

struct GridStackView_Previews: PreviewProvider
{
    @State static var TVals: [Bool] = [true, false]
    
    static var previews: some View
    {
        GeometryReader
        {
            Geometry in
        GridStackView(GridRows: 2, GridColumns: 3)
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
                                        self.TVals[Row]
                                    },
                            set:
                                {
                                    NewValue in
                                    TVals[Row] = NewValue
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
        .padding()
        }
    }
}
