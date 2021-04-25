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
    
    private static var _Initialized: Bool = false
    public static var Initialized: Bool
    {
        get
        {
            return _Initialized
        }
    }
    
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
    
    static func GroupListWithIDs() -> [IDString]
    {
        if !Initialized
        {
            Initialize()
        }
        return GroupList.map({IDString(id: $0, Value: $0)})
    }
    
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
    
    static func FilterListWithIDs(Index: Int) -> [IDString]
    {
        if !Initialized
        {
            Initialize()
        }
        return FilterListWithIDs(Group: GroupList[Index])
    }
    
    static var GroupList = [String]()
    static var GroupColors = [UIColor]()
    static var GroupFilterNames = [String: [String]]()
}
