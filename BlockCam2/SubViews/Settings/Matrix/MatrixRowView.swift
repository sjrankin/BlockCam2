//
//  MatrixRowView.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/14/21.
//

import SwiftUI

struct MatrixRowView: View
{
    @Binding var Values: [String]
    @State var ColumnCount: Int
    @Binding var EnabledColumnCount: Int
    @Binding var EnabledRowCount: Int
    @State var Row: Int
    @State var Updated: Bool = false
    @Binding var ChangedIndex: Int
    
    var body: some View
    {
        GeometryReader
        {
            Geometry in
            HStack
            {
                ForEach(0 ..< ColumnCount, id: \.self)
                {
                    Index in
                    MatrixCellView(CellValue: $Values[Index],
                                   CellWidth: Geometry.size.width * 0.14,
                                   CellX: Index,
                                   CellY: Row,
                                   Enabled: Index < EnabledColumnCount && Row < EnabledRowCount,
                                   Updated: Updated)
                        .onChange(of: Values[Index])
                        {
                            NewValue in
                            ChangedIndex = Index
                            Updated.toggle()
                            Values[Index] = NewValue
                        }
                }
            }
            .background(Updated ? Color.pink : Color.white)
            .padding(.bottom, 2)
            .frame(alignment: .center)
        }
    }
}

struct MatrixRowView_Previews: PreviewProvider
{
    @State static var TestValues: [String] = ["0.0", "0.1", "0.2", "0.3", "0.4"]
    @State static var Columns: Int = 5
    @State static var RowIndex: Int = 0
    @State static var EnabledColumns: Int = 3
    @State static var EnabledRows: Int = 3
    @State static var UpdatedColumn: Int = -1
    
    static var previews: some View
    {
        MatrixRowView(Values: $TestValues, 
                      ColumnCount: Columns,
                      EnabledColumnCount: $EnabledColumns,
                      EnabledRowCount: $EnabledRows,
                      Row: RowIndex,
                      ChangedIndex: $UpdatedColumn)
            .padding()
            .onChange(of: UpdatedColumn)
            {
                NewValue in
            }
    }
}
