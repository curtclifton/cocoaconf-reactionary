//
//  Goal.swift
//  SmartGoals
//
//  Created by Curt Clifton on 2/2/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation

#error HERE is where you're working.
// CCC, 4/10/2016. Need to decide how to handle mapping references between core data and value types. Should we just make all the references to generic SGMIdentifiedObjects? arrays of IDs? actual references? If actual references, we'll have to make updateFromValue() take a context so it can get the objects. That's seems very heavy.

extension SGMGoal: ModelValueUpdatable {
    func updateFromValue<Value : ModelValue>(value: Value) {
        guard let goal = value as? Goal else {
            fatalError("Attempting to update SGMGoal from non-Goal value: \(value)")
        }
        
        self.title = goal.title
        self.outcomeDescription = goal.outcomeDescription
        self.evaluationMetricDescription = goal.evaluationMetricDescription
        self.roleSupported = SGMRole() // CCC, 4/10/2016. need to get from ID on goal to actual object, hrmm
        self.goalsSupported = nil // CCC, 4/10/2016.

        self.reviews = nil // CCC, 4/10/2016.
    }
}

public struct Goal: ModelValue, Reviewable {
    public static var entityName: String {
        return SGMGoal.entityName
    }
    
    public static var fetchRequest: NSFetchRequest {
        return SGMGoal.fetchRequest()
    }
    
    public let identifier: Identifier<Goal>
    
    public let title: String
    public let outcomeDescription: String
    public let evaluationMetricDescription: String
    public let roleSupported: Identifier<Role>
    
    public let goalsSupported: [Identifier<Goal>]
    
    public let reviews: [Identifier<Review>]
    
    public init?(fromObject: AnyObject) {
        guard let object = fromObject as? SGMGoal else {
            return nil
        }
        self.identifier = object.identifier
        
        self.title = object.title ?? ""
        self.outcomeDescription = object.outcomeDescription ?? ""
        self.evaluationMetricDescription = object.evaluationMetricDescription ?? ""
        self.roleSupported = object.roleSupported!.identifier // must be defined
        
        self.goalsSupported = [] // CCC, 4/10/2016. extract from object.goalsSupported
        
        self.reviews = [] // CCC, 4/10/2016. extract from object.reviews
    }
}


