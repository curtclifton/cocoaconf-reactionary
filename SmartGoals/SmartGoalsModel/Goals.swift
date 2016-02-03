//
//  Goals.swift
//  SmartGoals
//
//  Created by Curt Clifton on 2/2/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation

public struct GoalSet {
    let identifier: Identifier<GoalSet>
    
    public let goals: [Goal]
    public let roles: [Role]
    
    /// like "January 2016" or "Due June 2017"
    public let name: String

    public let startDate: NSDate
    public let targetDate: NSDate
    
    public let reviews: [Review]
}

public struct Goal {
    let identifier: Identifier<Goal>
    
    public let title: String
    public let outcomeDescription: String
    public let evaluationMetricDescription: String
    
    public let relatedGoals: [Goal]
}


