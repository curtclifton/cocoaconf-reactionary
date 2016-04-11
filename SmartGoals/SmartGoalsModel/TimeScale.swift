//
//  TimeScale.swift
//  SmartGoals
//
//  Created by Curt Clifton on 2/2/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation

extension SGMTimeScale: ModelValueUpdatable {
    func updateFromValue<Value : ModelValue>(value: Value) {
        guard let timeScale = value as? TimeScale else {
            fatalError("Attempting to update SGMTimeScale from non-TimeScale value: \(value)")
        }
        self.timeScaleDescription = timeScale.timeScaleDescription
        self.goalSets = nil // CCC, 4/10/2016. need to get from IDs on timeScale to actual objects
    }
}

public struct TimeScale: ModelValue {
    public static var entityName: String {
        return SGMTimeScale.entityName
    }
    
    public static var fetchRequest: NSFetchRequest {
        return SGMTimeScale.fetchRequest()
    }
    
    public let identifier: Identifier<TimeScale>
    
    public let timeScaleDescription: String
    public let goalSets: [Identifier<GoalSet>]
    
    public init?(fromObject: AnyObject) {
        guard let object = fromObject as? SGMTimeScale else {
            return nil
        }
        self.identifier = object.identifier
    
        self.timeScaleDescription = object.timeScaleDescription ?? ""
        
        // CCC, 4/10/2016. Seems like we should be able to write this as an extension on Set
        if let goalSets = object.goalSets as? Set<SGMGoalSet> {
            self.goalSets = goalSets.map { goalSet in goalSet.identifier }
        } else {
            self.goalSets = []
        }
    }
}