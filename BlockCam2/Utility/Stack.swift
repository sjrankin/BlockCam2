//
//  Stack.swift
//  BlockCam2
//  Adapted from FlatlandView, 12/25/20.
//
//  Created by Stuart Rankin on 4/28/21.
//

import Foundation

/// Implements a simple generic stack. With a few sneaky extras.
class Stack<T>
{
    /// Initializer.
    init()
    {
        _Stack = [T]()
    }
    
    /// Where the stack data lives.
    var _Stack: [T]? = nil
    
    /// Push the passed item onto the stack.
    ///
    /// - Parameter Item: The item to push onto the stack.
    func Push(_ Item: T)
    {
        _Stack?.append(Item)
    }
    
    /// Pop the top of the stack and return it.
    ///
    /// - Returns: The top of the stack.
    func Pop() -> T?
    {
        if _Stack!.count < 1
        {
            return nil
        }
        let Popped = _Stack?.last
        _Stack?.removeLast()
        return Popped
    }
    
    /// Return the top of the stack but don't pop it.
    ///
    /// - Returns: The top of the stack (which is left in place).
    func PeekAtTop() -> T?
    {
        if Count < 1
        {
            return nil
        }
        return _Stack?.last
    }
    
    /// Peek at the specified location in the stack.
    ///
    /// - Parameter At: The item in the stack to return.
    /// - Returns: The item at the Atth location in the stack. Nil if the value of `At` is invalid (eg,
    ///            out of range).
    func Peek(At: Int) -> T?
    {
        if At < 0
        {
            return nil
        }
        if At >= Count
        {
            return nil
        }
        return _Stack?[At]
    }
    
    /// Implementation of the subscript operators. Syntactic wrapper around `Peek(:Int)`.
    ///
    /// - Parameter Index: Index of the item to return. Nil if out of range.
    subscript(Index: Int) -> T?
    {
        get
        {
            return Peek(At: Index)
        }
    }
    
    /// Returns the number of items in the stack.
    var Count: Int
    {
        get
        {
            return _Stack!.count
        }
    }
    
    /// Returns the empty flag.
    var IsEmpty: Bool
    {
        get
        {
            return Count < 1 ? true: false
        }
    }
    
    /// Clears the contents of the Stack.
    func Clear()
    {
        _Stack?.removeAll()
    }
    
    /// Returns the first item pushed onto the stack and clears the stack.
    /// - Returns: The first item pushed onto the stack. Nil if the stack is already empty.
    func PopToEmpty() -> T?
    {
        if IsEmpty
        {
            return nil
        }
        let First = _Stack?[0]
        Clear()
        return First
    }
}
