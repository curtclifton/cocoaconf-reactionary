//
//  SignalTests.swift
//  SmartGoals
//
//  Created by Curt Clifton on 2/15/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import XCTest
@testable import SmartGoalsModel

class SignalTests: XCTestCase {

    // CCC, 3/7/2016. Add tests of map
    
    // CCC, 3/7/2016. Add tests of flatmap
    
//    func testValueOnlyMap1() {
//        let stringSignal = Signal<String>()
//        var results: [Int] = []
//        stringSignal
//            .map(Result<String>.transform(forValueHandler: { Int($0) }))
//            .map(Result<Int>.transform(forValueHandler: { results.append($0) }))
//        stringSignal.updateToValue("1")
//        XCTAssertEqual(results, [1])
//        stringSignal.updateToValue("2")
//        XCTAssertEqual(results, [1, 2])
//        stringSignal.updateToValue("3")
//        XCTAssertEqual(results, [1, 2, 3])
//        stringSignal.updateToValue("dog")
//        XCTAssertEqual(results, [1, 2, 3])
//    }
//    
//    func testValueOnlyMap2() {
//        struct TestError: ErrorType {}
//        let stringSignal = Signal<String>()
//        var results: [Int] = []
//        stringSignal
//            .errorPassthroughMap { (string: String) -> Result<Int> in
//                guard let integerValue = Int(string) else {
//                    return .error(TestError())
//                }
//                return .value(integerValue)
//            }
//            .valueOnlyMap { (val: Int) -> () in
//                results.append(val)
//            }
//        stringSignal.updateToValue("1")
//        XCTAssertEqual(results, [1])
//        stringSignal.updateToValue("2")
//        XCTAssertEqual(results, [1, 2])
//        stringSignal.updateToValue("3")
//        XCTAssertEqual(results, [1, 2, 3])
//        
//        // valueOnlyMap shouldn't get error from converting "dog"
//        stringSignal.updateToValue("dog")
//        XCTAssertEqual(results, [1, 2, 3])
//        
//        stringSignal.updateToValue("4")
//        XCTAssertEqual(results, [1, 2, 3, 4])
//    }
//
//    func testErrorMaps() {
//        struct TestError: ErrorType {}
//        let stringSignal = Signal<String>()
//        var results: [Int] = []
//        var errorCount = 0
//        stringSignal
//            .errorPassthroughMap { (string: String) -> Result<Int> in
//                guard let integerValue = Int(string) else {
//                    return .error(TestError())
//                }
//                return .value(integerValue)
//            }
//            .errorHandlerMap { (error: ErrorType) -> Result<Int> in
//                errorCount += 1
//                return .error(error)
//            }
//            .valueOnlyMap { (val: Int) -> () in
//                results.append(val)
//        }
//        stringSignal.updateToValue("1")
//        XCTAssertEqual(results, [1])
//        XCTAssertEqual(errorCount, 0)
//
//        stringSignal.updateToValue("2")
//        XCTAssertEqual(results, [1, 2])
//        XCTAssertEqual(errorCount, 0)
//        
//        stringSignal.updateToValue("3")
//        XCTAssertEqual(results, [1, 2, 3])
//        XCTAssertEqual(errorCount, 0)
//        
//        // valueOnlyMap shouldn't get error from converting "dog"
//        stringSignal.updateToValue("dog")
//        XCTAssertEqual(results, [1, 2, 3])
//        // but errorHandlerMap should
//        XCTAssertEqual(errorCount, 1)
//        
//        stringSignal.updateToValue("4")
//        XCTAssertEqual(results, [1, 2, 3, 4])
//        XCTAssertEqual(errorCount, 1)
//    }
}
