//
//  Goal.swift
//  SmartGoals
//
//  Created by Curt Clifton on 2/2/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation

// CCC, 4/10/2016. Need to decide how to handle mapping references between core data and value types. Should we just make all the references to generic SGMIdentifiedObjects? arrays of IDs? (see https://gregheo.com/blog/core-data-transformable/ ) actual references? If actual references, we'll have to make updateFromValue() take a context so it can get the objects. That's seems very heavy.

extension SGMGoal: ModelValueUpdatable {
    func updateFromValue<Value : ModelValue>(value: Value) {
        guard let goal = value as? Goal else {
            fatalError("Attempting to update SGMGoal from non-Goal value: \(value)")
        }
        
        self.title = goal.title
        self.outcomeDescription = goal.outcomeDescription
        self.evaluationMetricDescription = goal.evaluationMetricDescription
        self.roleSupportedID = goal.roleSupported.uuid
        self.goalsSupportedIDs = Identifier<Goal>.arrayObjectFrom(identifiers: goal.goalsSupported)

        self.reviewsIDs = Identifier<Review>.arrayObjectFrom(identifiers: goal.reviews)
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
        self.roleSupported = Identifier(uuid: object.roleSupportedID)
        self.goalsSupported = Identifier<Goal>.from(arrayObject: object.goalsSupportedIDs)
        
        self.reviews = Identifier<Review>.from(arrayObject: object.reviewsIDs)
    }
}


