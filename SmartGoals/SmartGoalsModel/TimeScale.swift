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
    
    public var timeScaleDescription: String
    
    public init?(fromObject: AnyObject) {
        guard let object = fromObject as? SGMTimeScale else {
            return nil
        }
        self.identifier = object.identifier
    
        self.timeScaleDescription = object.timeScaleDescription ?? ""
    }
}