//
//  +Matrix.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/14/21.
//

import Foundation
import UIKit

extension Settings
{
    // MARK: - Matrix functions.
    // Matrices are two-dimensional arrays of type Double. Matrices are stored as strings in `UserSettings`.
    
    /// Initialize a matrix setting.
    /// - Warning: If `Setting` points to an incorrect type, a fatal error will be thrown.
    /// - Parameter Setting: The setting key where the matrix will be saved.
    /// - Parameter Value: The matrix to save.
    public static func InitializeMatrix(_ Setting: SettingKeys, _ Value: [[Double]])
    {
        guard TypeIsValid(Setting, Type: [[Double]].self) else
        {
            Debug.FatalError("\(Setting) is not [[Double]]")
        }
        let Serialized = SerializeMatrix(Value)
        UserDefaults.standard.set(Serialized, forKey: Setting.rawValue)
    }
    
    /// Returns a two-dimensional matrix from the passed setting key.
    /// - Warning: If `Setting` points to an incorrect type, a fatal error will be thrown.
    /// - Parameter Setting: The setting key where the matrix will be retrieved from.
    /// - Parameter CreateIfEmpty: If true, an empty array of the specified size is returned.
    /// - Parameter WidthIfEmpty: Width of the empty array if not found.
    /// - Parameter HeightIfEmpty: Height of the empty array if not found.
    /// - Returns: Two-dimensional array of `Double` values on success, nil on error. `[[0.0]]` is returned
    ///            if the stored value is empty.
    public static func GetMatrix(_ Setting: SettingKeys,
                                 CreateIfEmpty: Bool = true,
                                 WidthIfEmpty: Int = 5,
                                 HeightIfEmpty: Int = 5) -> [[Double]]?
    {
        guard TypeIsValid(Setting, Type: [[Double]].self) else
        {
            Debug.FatalError("\(Setting) is not [Double].")
        }
        guard let Serialized = UserDefaults.standard.string(forKey: Setting.rawValue) else
        {
            if CreateIfEmpty
            {
                var Matrix = [[Double]]()
                for Row in 0 ..< HeightIfEmpty
                {
                    var SomeRow = [Double]()
                    for Column in 0 ..< HeightIfEmpty
                    {
                        if Row == Column
                        {
                            SomeRow.append(1.0)
                        }
                        else
                        {
                            SomeRow.append(0.0)
                        }
                    }
                    Matrix.append(SomeRow)
                }
                return Matrix
            }
            return [[0.0]]
        }
        let Deserialized = DeserializeMatrix(Serialized)
        return Deserialized
    }
    
    /// Returns a matrix in user settings as a two-dimensional array of strings.
    /// - Warning: If `Setting` points to an incorrect type, a fatal error will be thrown.
    /// - Parameter Setting: The location in user settings where the matrix is stored.
    /// - Parameter CreateIfEmpty: If true, an empty array of the specified size is returned.
    /// - Parameter WidthIfEmpty: Width of the empty array if not found.
    /// - Parameter HeightIfEmpty: Height of the empty array if not found.
    /// - Returns: Two-dimensional array of strings, each representing a double.
    public static func GetMatrixAsString(_ Setting: SettingKeys,
                                         CreateIfEmpty: Bool = true,
                                         WidthIfEmpty: Int = 5,
                                         HeightIfEmpty: Int = 5) -> [[String]]
    {
        guard TypeIsValid(Setting, Type: [[Double]].self) else
        {
            Debug.FatalError("\(Setting) is not [Double].")
        }
        guard let Matrix = GetMatrix(Setting) else
        {
            if CreateIfEmpty
            {
                var Matrix = [[String]]()
                for Row in 0 ..< HeightIfEmpty
                {
                    var SomeRow = [String]()
                    for Column in 0 ..< HeightIfEmpty
                    {
                        if Row == Column
                        {
                            SomeRow.append("1.0")
                        }
                        else
                        {
                            SomeRow.append("0.0")
                        }
                    }
                    Matrix.append(SomeRow)
                }
                return Matrix
            }
            return [["0.0"]]
        }
        return ConvertToStringMatrix(Matrix)
    }
    
    /// Saves a two-dimensional array of strings into user settings.
    /// - Warning: If `Setting` points to an incorrect type, a fatal error will be thrown.
    /// - Parameter Setting: The location in user settings where the matrix will be stored.
    /// - Parameter Value: The two-dimensional array of strings to save.
    public static func SetMatrixAsString(_ Setting: SettingKeys, _ Value: [[String]])
    {
        guard TypeIsValid(Setting, Type: [[Double]].self) else
        {
            Debug.FatalError("\(Setting) is not [Double].")
        }
        let Matrix = ConvertToDoubleMatrix(Value)
        SetMatrix(Setting, Matrix)
    }
    
    /// Saves the passed two-dimensional array of `Double` values at the specified settings location.
    /// - Warning: If `Setting` points to an incorrect type, a fatal error will be thrown.
    /// - Parameter Setting: The location in user settings where the matrix will be stored.
    /// - Parameter Value: The two-dimensional array of `Double`s to save.
    public static func SetMatrix(_ Setting: SettingKeys, _ Value: [[Double]])
    {
        guard TypeIsValid(Setting, Type: [[Double]].self) else
        {
            Debug.FatalError("\(Setting) is not [Double].")
        }
        let Serialized = SerializeMatrix(Value)
        UserDefaults.standard.set(Serialized, forKey: Setting.rawValue)
        NotifySubscribers(Setting: Setting, OldValue: nil, NewValue: nil)
    }
    
    /// Serialize the passed matrix. Intended to be used internally. Prepends certain values. Used when saving
    /// data to the user settings.
    /// - Parameter Matrix: The two-dimensional array to serialize.
    /// - Returns: String representation of the passed `Matrix` data.
    public static func SerializeMatrix(_ Matrix: [[Double]]) -> String
    {
        if Matrix.isEmpty
        {
            return "W0,H0"
        }
        var Result = ""
        let Height = Matrix.count
        let Width = Matrix[0].count
        Result.append("W\(Width),H\(Height),")
        for Row in 0 ..< Height
        {
            for Column in 0 ..< Width
            {
                Result.append("\(Matrix[Row][Column]),")
            }
        }
        return Result
    }
    
    /// Deserialize a string serialized wtih `SerializeMatrix`. Intended for internal use only.
    /// - Parameter Raw: The string to deserialize.
    /// - Returns: Two-dimensional array of `Double` values based on the contents of `Raw`. On error,
    ///            `[[0.0]]` is returned.
    public static func DeserializeMatrix(_ Raw: String) -> [[Double]]
    {
        if Raw.isEmpty
        {
            return [[0.0]]
        }
        let Parts = Raw.split(separator: ",", omittingEmptySubsequences: true)
        if Parts.count < 3
        {
            return [[0.0]]
        }
        var WidthString = String(Parts[0])
        WidthString.removeFirst()
        guard let Width = Int(WidthString) else
        {
            return [[0.0]]
        }
        var HeightString = String(Parts[1])
        HeightString.removeFirst()
        guard let Height = Int(HeightString) else
        {
            return [[0.0]]
        }
        var RowItemCount = 0
        var Results = [[Double]]()
        var CurrentRow = [Double]()
        for Index in 2 ..< Parts.count
        {
            RowItemCount += 1
            let NodeValue = Double(String(Parts[Index])) ?? 0.0
            CurrentRow.append(NodeValue)
            if RowItemCount > Width - 1
            {
                RowItemCount = 0
                Results.append(CurrentRow)
                CurrentRow.removeAll()
            }
        }
        return Results
    }
    
    /// Convert the passed two-dimensional array of `Double`s into a two-dimensional array of `String`s.
    /// - Parameter Matrix: The two-dimensional array of `Double` values to convert.
    /// - Parameter RoundTo: Number of significant places to round values to when converting to strings.
    /// - Returns: Two-dimensional array of `String` values that corresponds to `Matrix.`
    public static func ConvertToStringMatrix(_ Matrix: [[Double]], RoundTo Precision: Int = 2) -> [[String]]
    {
        var Result = [[String]]()
        for Y in 0 ..< Matrix.count
        {
            var RowData = [String]()
            for X in 0 ..< Matrix[0].count
            {
                let Value = Matrix[Y][X]
                RowData.append("\(Value.RoundedTo(Precision))")
            }
            Result.append(RowData)
        }
        return Result
    }
    
    /// Convert the passed two-dimensional array of `String`s into a two-dimensional array of `Double`s.
    /// - Parameter Matrix: The two-dimensional array of `String` values to convert.
    /// - Returns: Two-dimensional array of `Double` values that corresponds to `Matrix.`
    public static func ConvertToDoubleMatrix(_ Matrix: [[String]]) -> [[Double]]
    {
        var Result = [[Double]]()
        for Y in 0 ..< Matrix.count
        {
            var RowData = [Double]()
            for X in 0 ..< Matrix[0].count
            {
                let Value = Double(Matrix[Y][X]) ?? 0.0
                RowData.append(Value)
            }
            Result.append(RowData)
        }
        return Result
    }
}
