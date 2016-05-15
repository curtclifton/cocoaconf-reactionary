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
    
    func testOneShotSignal() {
        let intSignal = UpdatableSignal<Int>()
        let oneShot = OneShotSignal(signal: intSignal)
        
        var firstNotificationCount = 0
        oneShot.map { _ in
            firstNotificationCount += 1
        }
        XCTAssert(firstNotificationCount == 0, "no value on signal yet, so shouldn't have counted")
        intSignal.update(toValue: 0)
        XCTAssert(firstNotificationCount == 1, "should count value on signal")
        
        var secondNotificationCount = 0
        oneShot.map { _ in
            secondNotificationCount += 1
        }
        XCTAssert(secondNotificationCount == 1, "value on signal, so should count immediately")
        
        // Finally, update signal again. Nothing should be notified:
        intSignal.update(toValue: 1)
        XCTAssert(firstNotificationCount == 1, "should be unchanged")
        XCTAssert(secondNotificationCount == 1, "should be unchanged")
    }
}
