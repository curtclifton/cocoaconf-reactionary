//
//  Result.swift
//  SmartGoals
//
//  Created by Curt Clifton on 5/27/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation

public enum Result<Value, Error: ErrorType> {
    case value(_: Value)
    case error(_: Error)
    
    public func extract() throws -> Value {
        switch self {
        case value(let value):
            return value
        case error(let error):
            throw error
        }
    }
    
    public var unwrapped: Value? {
        switch self {
        case value(let value):
            return value
        default:
            return nil
        }
    }
}