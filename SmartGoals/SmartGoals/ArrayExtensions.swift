//
//  ArrayExtensions.swift
//  SmartGoals
//
//  Created by Curt Clifton on 4/26/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation

extension Array {
    subscript(index: Int, defaultValue defaultValue: Element?) -> Element? {
        get {
            guard 0 <= index && index < count else {
                return defaultValue
            }
            return self[index]
        }
    }
    
    func split(atIndex index: Int) -> (ArraySlice<Element>, ArraySlice<Element>) {
        let cappedIndex = min(index, count)
        let first = self.prefixUpTo(cappedIndex)
        let second = self.suffixFrom(cappedIndex)
        return (first, second)
    }
}
