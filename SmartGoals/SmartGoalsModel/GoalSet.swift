//
//  GoalSet.swift
//  SmartGoals
//
//  Created by Curt Clifton on 4/10/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation

extension SGMGoalSet: ModelValueUpdatable {
    func updateFromValue<Value : ModelValue>(value: Value) {
        guard let goalSet = value as? GoalSet else {
            fatalError("Attempting to update SGMGoalSet from non-GoalSet value: \(value)")
        }
        
        self.goals = nil // CCC, 4/10/2016. Need to get from array of IDs on goalSet to actual references, hrmm
        self.roles = nil // CCC, 4/10/2016.
        
        self.targetDate = goalSet.targetDate.timeIntervalSinceReferenceDate
        
        self.reviews = nil // CCC, 4/10/2016.
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
    
    public let goals: [Identifier<Goal>]
    public let roles: [Identifier<Role>]
    
    public let targetDate: NSDate
    
    public let reviews: [Identifier<Review>]
    
    public init?(fromObject: AnyObject) {
        guard let object = fromObject as? SGMGoalSet else {
            return nil
        }
        self.identifier = object.identifier
        
        // CCC, 4/10/2016. Seems like we should be able to write this as an extension on Set
        if let goals = object.goals as? Set<SGMGoal> {
            self.goals = goals.map { goal in goal.identifier }
        } else {
            self.goals = []
        }
        
        self.roles = [] // CCC, 4/10/2016. extract from object.roles
        
        self.targetDate = NSDate(timeIntervalSinceReferenceDate: object.targetDate)
        
        self.reviews = [] // CCC, 4/10/2016. extract from object.reviews
    }
}
