//
//  Goals.swift
//  SmartGoals
//
//  Created by Curt Clifton on 2/2/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation

// CCC, 2/7/2016. All the model objects should probably be classes, not structs.
public struct GoalSet {
    let identifier: Identifier<GoalSet>
    
    public let goals: [Goal]
    public let roles: [Role]
    
    public let targetDate: NSDate
    
    public let reviews: [Review]
}

public struct Goal {
    let identifier: Identifier<Goal>
    
    public let title: String
    public let outcomeDescription: String
    public let evaluationMetricDescription: String
    
    public let goalsSupported: [Goal]
    
    public let reviews: [Review]
}


