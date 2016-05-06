//
//  SignalTests.swift
//  SmartGoals
//
//  Created by Curt Clifton on 2/15/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import XCTest
@testable import Reactionary

class SignalTests: XCTestCase {
    func testMap() {
        let stringSignal = UpdatableSignal<String>()
        var results: [Int] = []
        stringSignal
            .map({ Int($0) })
            .map({ if $0 != nil { results.append($0!) } })
        stringSignal.update(toValue: "1")
        XCTAssertEqual(results, [1])
        stringSignal.update(toValue: "2")
        XCTAssertEqual(results, [1, 2])
        stringSignal.update(toValue: "3")
        XCTAssertEqual(results, [1, 2, 3])
        stringSignal.update(toValue: "dog")
        XCTAssertEqual(results, [1, 2, 3])
    }
    
    func testFlatMap() {
        let stringSignal = UpdatableSignal<String>()
        var results: [Int] = []
        stringSignal
            .flatmap({ Int($0) })
            .map({ results.append($0) })
        stringSignal.update(toValue: "1")
        XCTAssertEqual(results, [1])
        stringSignal.update(toValue: "2")
        XCTAssertEqual(results, [1, 2])
        stringSignal.update(toValue: "3")
        XCTAssertEqual(results, [1, 2, 3])
        stringSignal.update(toValue: "dog")
        XCTAssertEqual(results, [1, 2, 3])
    }
}
