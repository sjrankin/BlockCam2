//
//  MatrixEntryView.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/14/21.
//

import SwiftUI

struct MatrixEntryView: View
{
    @Binding var Kernel: [[String]]
    @State var ColumnCount: Int
    @State var RowCount: Int
    @Binding var EnabledColumnCount: Int
    @Binding var EnabledRowCount: Int
    @State var ChangedIndex: Int = -1
    @State var Updated: Bool
    
    var body: some View
    {
        GeometryReader
        {
            Geometry in
            LazyVStack
            {
                ForEach(0 ..< RowCount, id: \.self)
                {
                    Index in
                    MatrixRowView(Values: $Kernel[Index],
                                  ColumnCount: ColumnCount,
                                  EnabledColumnCount: $EnabledColumnCount,
                                  EnabledRowCount: $EnabledRowCount,
                                  Row: Index,
                                  Updated: Updated,
                                  ChangedIndex: $ChangedIndex)
                        .frame(width: Geometry.size.width * 0.8,
                               alignment: .center)
                        .padding()
                        .onChange(of: Kernel[Index])
                        {
                            NewValue in
                        }
                }
                .frame(alignment: .center)
            }
        }
    }
}

struct MatrixEntryView_Previews: PreviewProvider
{
    @State static var KernelData =
    [
        ["1.0", "0.0", "0.0", "0.0", "0.0"],
        ["0.0", "1.0", "0.0", "0.0", "0.0"],
        ["0.0", "0.0", "1.0", "0.0", "0.0"],
        ["0.0", "0.0", "0.0", "1.0", "0.0"],
        ["0.0", "0.0", "0.0", "0.0", "1.0"],
    ]
    @State static var Columns: Int = 5
    @State static var Rows: Int = 5
    @State static var EnabledColumns: Int = 3
    @State static var EnabledRows: Int = 3
    @State static var Updated: Bool = false
    
    static var previews: some View
    {
        MatrixEntryView(Kernel: $KernelData,
                        ColumnCount: Columns,
                        RowCount: Rows,
                        EnabledColumnCount: $EnabledColumns,
                        EnabledRowCount: $EnabledRows,
                        Updated: Updated)
            .onChange(of: KernelData)
            {
                NewValue in
                print("New data received in MatrixEntryView")
            }
    }
}

