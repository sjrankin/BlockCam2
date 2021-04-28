//
//  FilterData.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/24/21.
//

import Foundation
import SwiftUI

/// Presents filter data for the user interface.
class FilterData
{
    /// Initialization.
    /// - Warning: If not called, fatal errors will be thrown when functions are accessed.
    /// - Note: To avoid fatal errors, initialization flags are used for various calls and if the class hasn't
    ///         been initialized, this function will be called.
    static func Initialize()
    {
        if Initialized
        {
            return
        }
        if !Filters.Initialized
        {
            Filters.InitializeFilters()
            Filters.InitializeFilterTree()
        }
        for (Group, GroupFilters) in Filters.FilterTree
        {
            if !GroupFilters.isEmpty
            {
                GroupList.append(Group.rawValue)
            }
        }
        GroupList.sort()
        for Group in GroupList
        {
            let RawColorValue = Filters.GroupData[FilterGroups(rawValue: Group)!] ?? 0xffffff
            GroupColors.append(UIColor(RGB: RawColorValue))
        }
        for (Group, Filters) in Filters.FilterTree
        {
            let GroupName = Group.rawValue
            var FilterNames = [String]()
            for SomeFilter in Filters.keys
            {
               let FilterName = SomeFilter.rawValue
                FilterNames.append(FilterName)
            }
            FilterNames.sort()
            if FilterNames.count > 0
            {
            GroupFilterNames[GroupName] = FilterNames
            }
        }
        _Initialized = true
    }
    
    /// Holds the class initialized flag.
    private static var _Initialized: Bool = false
    /// Get the class initialized flag.
    public static var Initialized: Bool
    {
        get
        {
            return _Initialized
        }
    }
    
    /// Return the group name for the specified index value.
    /// - Warning: If the index value passed is out of range, a fatal error is thrown.
    /// - Note: The returned name is dependent on the alphabetized group list.
    /// - Parameter For: The index value whose group name will be returned.
    /// - Returns: `IDString` value containing the group name.
    static func GroupName(For Index: Int) -> IDString
    {
        if !Initialized
        {
            Initialize()
        }
        if Index > GroupList.count - 1
        {
            fatalError("Index \(Index) out of range in \(#function)")
        }
        return IDString(id: GroupList[Index], Value: GroupList[Index])
    }
    
    /// Return the group color for the specified index value.
    /// - Warning: If the index value passed is out of range, a fatal error is thrown.
    /// - Note: The returned color is dependent on the alphabetized group list.
    /// - Parameter For: The index value whose group color will be returned.
    /// - Returns: Color associated with the group.
    static func GroupColor(For Index: Int) -> UIColor
    {
        if !Initialized
        {
            Initialize()
        }
        if Index > GroupList.count - 1
        {
            fatalError("Index \(Index) out of range in \(#function)")
        }
        return GroupColors[Index]
    }
    
    /// Return the group color for the specified group name.
    /// - Warning: If the name passed results in an out of range index, a fatal error is thrown.
    /// - Note: The returned color is dependent on the alphabetized group list.
    /// - Parameter With: The name of the group whose color will be returned.
    /// - Returns: Color associated with the group.
    static func GroupColor(With Name: String) -> UIColor
    {
        if !Initialized
        {
            Initialize()
        }
        let GroupIndex = IndexOf(Group: Name)
        if GroupIndex > GroupColors.count - 1
        {
            fatalError("Invalid value \(GroupIndex) return to \(#function)")
        }
        return GroupColors[GroupIndex]
    }
    
    /// Returns the index (into an alphabetized group list) of the passed group name.
    /// - Warning: Throws a fatal error if the name is not found.
    /// - Parameter Group: The name whose index will be returned.
    /// - Returns: Index into an alphabetized group list of the passed group name.
    static func IndexOf(Group Name: String) -> Int
    {
        if !Initialized
        {
            Initialize()
        }
        if Name.isEmpty
        {
            fatalError("Empty parameter passed to \(#function)")
        }
       if let Index = GroupList.firstIndex(of: Name)
       {
        return Index
       }
        fatalError("Did not find group \(Name) in GroupList in \(#function)")
    }
    
    /// Returns an array of group names.
    /// - Returns: Array of group names encapsulated in `IDString` structures.
    static func GroupListWithIDs() -> [IDString]
    {
        if !Initialized
        {
            Initialize()
        }
        return GroupList.map({IDString(id: $0, Value: $0)})
    }
    
    /// Returns an array of filter names for a given group.
    /// - Parameter Group: The group whose filter names will be returned.
    /// - Returns: Array of alphabetized filter names, each encapsulated in an `IDString` structure.
    static func FilterListWithIDs(Group Name: String) -> [IDString]
    {
        if !Initialized
        {
            Initialize()
        }
        if let FilterList = GroupFilterNames[Name]
        {
            return FilterList.map({IDString(id: $0, Value: $0)})
        }
        return [IDString]()
    }
    
    /// Returns an array of filter names for the given group index.
    /// - Parameter Index: The index group whose filter names will be returned.
    /// - Returns: Array of alphabetized filter names, each encapsulated in an `IDString` structure.
    static func FilterListWithIDs(Index: Int) -> [IDString]
    {
        if !Initialized
        {
            Initialize()
        }
        return FilterListWithIDs(Group: GroupList[Index])
    }
    
    /// Holds a list of group names.
    static var GroupList = [String]()
    
    /// Holds a list of group colors.
    static var GroupColors = [UIColor]()
    
    /// Holds a list of filters for each group.
    static var GroupFilterNames = [String: [String]]()
}
