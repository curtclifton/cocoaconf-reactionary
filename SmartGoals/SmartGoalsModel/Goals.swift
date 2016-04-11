//
//  Goals.swift
//  SmartGoals
//
//  Created by Curt Clifton on 2/2/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation

// CCC, 4/5/2016. Add to model
public struct GoalSet: Reviewable {
    let identifier: Identifier<GoalSet>
    
    public let goals: [Identifier<Goal>]
    public let roles: [Identifier<Role>]
    
    public let targetDate: NSDate
    
    public let reviews: [Identifier<Review>]
}

public struct Goal: Reviewable {
    let identifier: Identifier<Goal>
    
    public let title: String
    public let outcomeDescription: String
    public let evaluationMetricDescription: String
    public let roleSupported: Identifier<Role>
    
    public let goalsSupported: [Identifier<Goal>]
    
    public let reviews: [Identifier<Review>]
}


