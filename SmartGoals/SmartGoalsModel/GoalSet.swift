//
//  GoalSet.swift
//  SmartGoals
//
//  Created by Curt Clifton on 4/10/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation
import CoreData

extension SGMGoalSet: ModelValueUpdatable {
    func updateFromValue<Value : ModelValue>(value: Value) {
        guard let goalSet = value as? GoalSet else {
            fatalError("Attempting to update SGMGoalSet from non-GoalSet value: \(value)")
        }
        
        self.goalsIDs = Identifier<Goal>.arrayObjectFrom(identifiers: goalSet.goals)
        self.rolesIDs = Identifier<Role>.arrayObjectFrom(identifiers: goalSet.roles)
        
        self.targetDate = goalSet.targetDate.timeIntervalSinceReferenceDate
        self.timeScaleID = goalSet.timeScale.uuid
            
        self.reviewsIDs = Identifier<Review>.arrayObjectFrom(identifiers: goalSet.reviews)
    }
}

public struct GoalSet: ModelValue, Reviewable {
    public static var entityName: String {
        return SGMGoalSet.entityName
    }
    
    public static var fetchRequest: NSFetchRequest {
        return SGMGoalSet.fetchRequest()
    }
    
    public let identifier: Identifier<GoalSet>
    
    public var goals: [Identifier<Goal>]
    public var roles: [Identifier<Role>]
    
    public var targetDate: NSDate
    public var timeScale: Identifier<TimeScale>
    public var reviews: [Identifier<Review>]
    
    public init?(fromObject: AnyObject) {
        guard let object = fromObject as? SGMGoalSet else {
            return nil
        }
        self.identifier = object.identifier
        
        self.goals = Identifier<Goal>.from(arrayObject: object.goalsIDs)
        self.roles = Identifier<Role>.from(arrayObject: object.rolesIDs)
        self.targetDate = NSDate(timeIntervalSinceReferenceDate: object.targetDate)
        self.timeScale = Identifier<TimeScale>(uuid: object.timeScaleID)
        self.reviews = Identifier<Review>.from(arrayObject: object.reviewsIDs)
    }
}
