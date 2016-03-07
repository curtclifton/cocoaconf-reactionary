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
    
    /// Creates a transform that applies `handler` to any non-error Results, passing through errors unchanged.
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
    
    /// Creates a transform that applies `handler` to any non-error Results, passing through all Results unchanged.
    public static func transform(forPassthroughValueHandler handler: Value -> ())  -> (Result<Value> -> Result<Value>) {
        let resultTransform = { (inputResult: Result<Value>) -> Result<Value> in
            switch inputResult {
            case .value(let value):
                handler(value)
            default:
                break
            }
            return inputResult
        }
        return resultTransform
    }
    
    /// Creates a transform that applies `handler` to any error Results, passing through all Results unchanged.
    public static func transform(forPassthroughErrorHandler handler: ErrorType -> ()) -> (Result<Value> -> Result<Value>) {
        let resultTransform = { (inputResult: Result<Value>) -> Result<Value> in
            switch inputResult {
            case .error(let error):
                handler(error)
            default:
                break
            }
            return inputResult
        }
        return resultTransform
    }

    // CCC, 3/6/2016. do we need an error transformer (e.g., handler: ErrorType -> ErrorType)?
}

