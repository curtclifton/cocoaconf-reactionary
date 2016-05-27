//
//  SmartGoalsModelTests.swift
//  SmartGoalsModelTests
//
//  Created by Curt Clifton on 1/26/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Reactionary
import XCTest

@testable import SmartGoalsModel

func afterDelay(delay: NSTimeInterval, perform: () -> ()) {
    let mainQueue = dispatch_get_main_queue()
    let nsDelay: Int64 = Int64(delay * Double(NSEC_PER_SEC))
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, nsDelay), mainQueue, perform)
}

struct RefulfillableExpectation {
    let expectation: XCTestExpectation
    var fulfilled: Bool = false

    init(_ expectation: XCTestExpectation) {
        self.expectation = expectation
    }
    
    mutating func fulfill() {
        if !fulfilled {
            fulfilled = true
            expectation.fulfill()
        }
    }
}

class SmartGoalsModelTests: XCTestCase {
    var testRootManagedObjectContext: SmartGoalsManagedObjectContext?
    var testModel: SmartGoalsModel?
    
    override func setUp() {
        super.setUp()
        testRootManagedObjectContext = SmartGoalsManagedObjectContext(name: "Test Root Context")
        testModel = SmartGoalsModel(managedObjectContext: testRootManagedObjectContext!)
    }
    
    func waitForExpectationsWithTimeout(timeout: NSTimeInterval) {
        waitForExpectationsWithTimeout(timeout) { error in
            if let actualError = error {
                print("failed wait for expectations: \(actualError)")
            }
        }
    }
    
    func testEntityNames() {
        let role = SGMRole.entityName
        XCTAssertEqual(role, "SGMRole")
    }
    
    func testEntityCreation() {
        var created = RefulfillableExpectation(expectationWithDescription("object created"))
        
        let signal = testModel!.valueSignalForNewInstanceOfType(Role.self)
        signal.map { role in
            print(role)
            created.fulfill()
        }
        
        waitForExpectationsWithTimeout(5)
    }
    
    func testValueSignal() {
        var id: Identifier<Role>? = nil
        var created = RefulfillableExpectation(expectationWithDescription("object created"))
        
        let createSignal1 = testModel!.valueSignalForNewInstanceOfType(Role.self)
        createSignal1.map { roleResult in
            id = roleResult.unwrapped!.identifier
            created.fulfill()
        }
        
        // Wait until first instantiation succeeds before setting up signal
        waitForExpectationsWithTimeout(5)
        XCTAssertNotNil(id)
        
        let signalled = expectationWithDescription("object signalled")
        let signal = testModel!.valueSignalForIdentifier(id!)
        signal.map { role in
            // Should be signalled immediately due to existing value inserted above
            signalled.fulfill()
        }
        
        // Instantiate another Role. This shouldn't affect `signal`, but if it does we'll raise attempting to fulfill the signalled expectation a second time.
        id = nil
        var created2 = RefulfillableExpectation(expectationWithDescription("object created"))
        let createSignal2 = testModel!.valueSignalForNewInstanceOfType(Role.self)
        createSignal2.map { roleResult in
            id = roleResult.unwrapped!.identifier
            created2.fulfill()
        }
        
        // Wait until second instantiation succeeds
        waitForExpectationsWithTimeout(5)
        XCTAssertNotNil(id)
        
        var signalled2 = RefulfillableExpectation(expectationWithDescription("second object signalled"))
        let signal2 = self.testModel!.valueSignalForIdentifier(id!)
        signal2.map { (role: Result<Role, FetchError>) -> Void in
            // Should be signalled immediately due to existing value
            signalled2.fulfill()
        }
        
        waitForExpectationsWithTimeout(5)
    }
    
    func testTypeSignal() {
        var gotZero = RefulfillableExpectation(expectationWithDescription("zero received"))
        var gotTwo = RefulfillableExpectation(expectationWithDescription("two received"))
        var instantiatedOne = RefulfillableExpectation(expectationWithDescription("instantiated one"))
        var instantiatedTwo = RefulfillableExpectation(expectationWithDescription("instantiated two"))
        var instantiatedThree = RefulfillableExpectation(expectationWithDescription("instantiated two"))
        
        let signal = self.testModel!.valuesSignalForType(Role.self)
        signal.map { roles in
            switch roles.count {
            case 0:
                gotZero.fulfill()
            case 1:
                // Depending on threading, we could get an update between instantiates, or not. Either is OK.
                break;
            case 2:
                gotTwo.fulfill()
            default:
                XCTFail("Where did the third object come from!")
            }
        }
        
        let createSignal1 = self.testModel!.valueSignalForNewInstanceOfType(Role.self)
        createSignal1.map { role in
            instantiatedOne.fulfill()
        }
        
        let createSignal2 = self.testModel!.valueSignalForNewInstanceOfType(Role.self)
        createSignal2.map { role in
            instantiatedTwo.fulfill()
        }
        
        // make sure instantiating a Review doesn't strobe the role values signal
        let createSignal3 = self.testModel!.valueSignalForNewInstanceOfType(Review.self)
        createSignal3.map { review in
            instantiatedThree.fulfill()
        }
        
        waitForExpectationsWithTimeout(5)
    }
    
    func testUpdateValue() {
        let signal = testModel!.valueSignalForNewInstanceOfType(Role.self)
        let gotInitialRole = expectationWithDescription("initial role created")
        
        var roleToUpdate: Role? = nil
        signal.map { roleResult in
            if roleToUpdate == nil {
                // first time through
                roleToUpdate = roleResult.unwrapped!
                gotInitialRole.fulfill()
            }
        }
        
        waitForExpectationsWithTimeout(5)

        let gotUpdatedRole = expectationWithDescription("role updated")
        let newShortName = "Updated"
        roleToUpdate!.shortName = newShortName
        testModel!.update(fromValue: roleToUpdate!)
        signal.map { roleResult in
            // Expect to be signalled with the original value on initial subscription, then again with the updated value.
            if roleResult.unwrapped!.shortName == newShortName {
                gotUpdatedRole.fulfill()
            }
        }
        
        waitForExpectationsWithTimeout(5)
    }
    
    func testUpdateValues() {
        // create two objects
        var gotInstanceOne = RefulfillableExpectation(expectationWithDescription("first instance"))
        var gotInstanceTwo = RefulfillableExpectation(expectationWithDescription("second instance"))
        let signal1 = testModel!.valueSignalForNewInstanceOfType(Role.self)
        let signal2 = testModel!.valueSignalForNewInstanceOfType(Role.self)
        var role1: Role?
        var role2: Role?
        
        signal1.map { roleResult in
            role1 = roleResult.unwrapped!
            gotInstanceOne.fulfill()
        }
        
        signal2.map { roleResult in
            role2 = roleResult.unwrapped!
            gotInstanceTwo.fulfill()
        }
        
        waitForExpectationsWithTimeout(5)
        
        // then create signal monitoring objects
        let gotOriginalValues = expectationWithDescription("original values")
        let gotUpdatedValues = expectationWithDescription("updated values")
        let monitorSignal = testModel!.valuesSignalForType(Role.self)
        var monitorCount = 0
        monitorSignal.map { _ in
            monitorCount += 1
            switch monitorCount {
            case 1:
                gotOriginalValues.fulfill()
            case 2:
                gotUpdatedValues.fulfill()
            default:
                XCTFail("Only expect to signal updates twice, otherwise update was non-atomic")
            }
        }

        // then update both objects
        let token = testModel!.beginUpdates()
        role1!.shortName = "Role 1"
        role2!.shortName = "Role 2"
        testModel!.update(fromValue: role1!, withToken: token)
        testModel!.update(fromValue: role2!, withToken: token)
        testModel!.endUpdates(forToken: token)

        waitForExpectationsWithTimeout(5)
    }
    
    func testDelete() {
        var stage = 0
        let gotNoRoles = expectationWithDescription("no roles")
        let gotOneRole = expectationWithDescription("one role")
        let gotNoRolesAgain = expectationWithDescription("no roles again")
        
        let rolesSignal = testModel!.valuesSignalForType(Role.self).signal(onQueue: .mainQueue())

        rolesSignal.map { (roles: [Role]) -> Void in
            switch stage {
            case 0:
                stage += 1
                XCTAssert(roles.count == 0)
                gotNoRoles.fulfill()
                let _ = self.testModel!.instantiateObjectOfType(Role.self)
            case 1:
                stage += 1
                XCTAssert(roles.count == 1)
                gotOneRole.fulfill()
                self.testModel!.delete(value: roles[0])
            case 2:
                stage += 1
                XCTAssert(roles.count == 0)
                gotNoRolesAgain.fulfill()
            default:
                XCTFail("should be reached")
            }
        }

        waitForExpectationsWithTimeout(5)
    }
    
    // CCC, 5/26/2016. need to test delete with an item fetch too
    
    func testReferences() {
        let reviewID = testModel!.instantiateObjectOfType(Review.self)
        let goalSetSignal = testModel!.valueSignalForNewInstanceOfType(GoalSet.self)
        let mainQueueGoalSetSignal = goalSetSignal.signal(onQueue: .mainQueue())
        
        var stage = 0
        let gotStageZero = expectationWithDescription("stage zero")
        let gotStageOne = expectationWithDescription("stage one")
        
        mainQueueGoalSetSignal.map { (goalSetResult) -> Void in
            var goalSet = goalSetResult.unwrapped!
            switch stage {
            case 0:
                stage += 1
                gotStageZero.fulfill()
                goalSet.reviews = [reviewID]
                self.testModel!.update(fromValue: goalSet)
            case 1:
                stage += 1
                gotStageOne.fulfill()
                XCTAssertEqual(goalSet.reviews, [reviewID])
            default:
                break
            }
        }

        waitForExpectationsWithTimeout(5)
    }
}
