//
//  Goals.swift
//  SmartGoals
//
//  Created by Curt Clifton on 2/2/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation

protocol Reviewable {
    let reviews: [Review]
}

struct GoalSet {
    let identifier: Identifier<GoalSet>
    
    let goals: [Goals]
    let roles: [Roles]
    
    /// like "January 2016" or "Due June 2017"
    let name: String

    let startDate: NSDate
    let targetDate: NSDate
    
    let reviews: [Review]
}

struct Goal {
    let identifier: Identifer<Goal>
    
    let title: String
    let outcomeDescription: String
    let evaluationMetricDescription: String
    
    let relatedGoals: [Goal]
}