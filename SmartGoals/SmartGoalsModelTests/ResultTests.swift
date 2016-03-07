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

    func testValuePassthroughHandlerWithValue() {
        let input = Result.value(1)
        var accum: [Int] = []
        
        let transform = Result.transform(forValuePassthroughHandler: { (x: Int) in accum.append(x) })
        let output = transform(input)
        
        XCTAssertEqual(accum, [1])
        XCTAssert(haveEqualValues(lhs: output, rhs: Result.value(1)))
    }
    
    func testValuePassthroughHandlerWithError() {
        let input = Result<Int>.error(testError)
        var accum: [Int] = []
        
        let transform = Result.transform(forValuePassthroughHandler: { (x: Int) in accum.append(x) })
        let output = transform(input)
        
        XCTAssertEqual(accum, [])
        XCTAssert(output.hasError(testError))
    }
    
    func testPassthroughErrorHandlerWithValue() {
        let input = Result.value(1)
        var wasHit = false
        
        let transform = Result<Int>.transform(forPassthroughErrorHandler: { (error: ErrorType) in wasHit = true })
        let output = transform(input)
        
        XCTAssertFalse(wasHit)
        XCTAssert(haveEqualValues(lhs: output, rhs: Result.value(1)))
    }
    
    func testPassthroughErrorHandlerWithError() {
        let input = Result<Int>.error(testError)
        var wasHit = false
        
        let transform = Result<Int>.transform(forPassthroughErrorHandler: { (error: ErrorType) in wasHit = true })
        let output = transform(input)
        
        XCTAssert(wasHit)
        XCTAssert(output.hasError(testError))
    }
    
}
