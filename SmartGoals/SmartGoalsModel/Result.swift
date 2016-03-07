//
//  Result.swift
//  SmartGoals
//
//  Created by Curt Clifton on 3/6/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation

public enum Result<Value> {
    case value(Value)
    case error(ErrorType)
    
    public static func transform<OutValue>(forValueHandler handler: Value -> OutValue) -> (Result<Value> -> Result<OutValue>) {
        let resultTransform = { (inputResult: Result<Value>) -> Result<OutValue> in
            switch inputResult {
            case .value(let value):
                return Result<OutValue>.value(handler(value))
            case .error(let error):
                return Result<OutValue>.error(error)
            }
        }
        return resultTransform
    }
    
    // CCC, 3/6/2016. implement and test other transforms
    public static func transform(forValuePassthroughHandler handler: Value -> ())  -> (Result<Value> -> Result<Value>) {
        let valueHandler = { (value: Value) -> Value in
            handler(value)
            return value
        }
        return transform(forValueHandler: valueHandler)
    }
    
    // CCC, 3/6/2016. can probably factor out the core of these
}

