//
//  ResultTests.swift
//  SmartGoals
//
//  Created by Curt Clifton on 3/6/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import XCTest
@testable import SmartGoalsModel

func haveEqualValues<T: Equatable>(lhs lhs: Result<T>, rhs: Result<T>) -> Bool {
    switch (lhs, rhs) {
    case let (.value(lhsValue), .value(rhsValue)):
        return lhsValue == rhsValue
    default:
        return false
    }
}

protocol ErrorClass: class {
}

extension Result {
    func hasError<E: ErrorType where E: ErrorClass>(expectedError: E) -> Bool {
        switch self {
        case .error(let error as E):
            return error === expectedError
        default:
            return false
        }
    }
}

class TestError: ErrorType, ErrorClass {
}

class ResultTests: XCTestCase {
    let testError = TestError()
    
    func testValueHandlerWithValue() {
        let input = Result.value(1)
        
        let transform = Result.transform(forValueHandler: { (x: Int) in String(x) })
        let output = transform(input)
        
        XCTAssert(haveEqualValues(lhs: output, rhs: Result.value("1")))
    }
    
    func testValueHandlerWithError() {
        let input = Result<Int>.error(testError)
        
        let transform = Result.transform(forValueHandler: { (x: Int) in String(x) })
        let output = transform(input)
        
        XCTAssert(output.hasError(testError))
    }
}
