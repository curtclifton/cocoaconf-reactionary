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
    
    func testDelayedSignal() {
        let delay: NSTimeInterval = 3.0
        let intSignal = UpdatableSignal<Int>()
        let delayedSignal = intSignal.signal(withDelay: delay)
        
        let gotDelayedSignal = expectationWithDescription("Delayed")
        var startTime: NSDate?
        var propagateTime: NSDate?
        intSignal.map { _ in
            startTime = NSDate()
        }
        delayedSignal.map { _ in
            propagateTime = NSDate()
            gotDelayedSignal.fulfill()
        }
        
        intSignal.update(toValue: 1)
        
        waitForExpectationsWithTimeout(delay + 2.0, handler: nil)
        guard let start = startTime, let end = propagateTime else {
            XCTFail("Did not set start or end time")
            return
        }
        
        let difference = round(end.timeIntervalSinceDate(start))
        XCTAssert(difference == delay, "Expected approximately \(delay) second delay. Got \(difference)")
    }
    
    func testZip2Signal() {
        let intSignal = UpdatableSignal<Int>()
        let stringSignal = UpdatableSignal<String>()
        
        var results: [(Int?, String?)] = []
        
        intSignal.signal(zippingWith: stringSignal).map { pair in results.append(pair) }
        
        intSignal.update(toValue: 0)
        stringSignal.update(toValue: "A")
        stringSignal.update(toValue: "B")
        intSignal.update(toValue: 1)
        
        let expectedResults: [(Int?, String?)] = [
            (0, nil),
            (0, "A"),
            (0, "B"),
            (1, "B"),
        ]
        
        XCTAssertEqual(results.count, expectedResults.count)
        for (result, expected) in zip(results, expectedResults) {
            XCTAssertEqual(result.0, expected.0)
            XCTAssertEqual(result.1, expected.1)
        }
    }
    
    func testWeakProxy() {
        let intSignal = UpdatableSignal<Int>()
        var strongResults: [Int] = []
        var weakResults: [Int] = []
        autoreleasepool {
            intSignal.map { strongResults.append($0) }
            let (transform, _) = intSignal.weakProxy.map { weakResults.append($0) }
            
            // push through some values that should land in both accumulators
            intSignal.update(toValue: 0)
            intSignal.update(toValue: 1)
            intSignal.update(toValue: 2)
            
            print("transform: \(transform)") // keeps compiler from complaining about unused `transform`
        }
        
        // push through values that should only land in strong accumulator
        intSignal.update(toValue: 3)
        intSignal.update(toValue: 4)
        
        XCTAssertEqual(strongResults, [0,1,2,3,4])
        XCTAssertEqual(weakResults, [0,1,2])
    }
}
