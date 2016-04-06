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
    
    public let goals: [Goal] // CCC, 3/29/2016. identifiers instead?
    public let roles: [Role] // CCC, 3/29/2016. identifiers instead?
    
    public let targetDate: NSDate
    
    public let reviews: [Review] // CCC, 3/29/2016. identifiers instead?
}

#error HERE is where you're working.
// CCC, 4/5/2016. Add to model
public struct Goal: Reviewable {
    let identifier: Identifier<Goal>
    
    public let title: String
    public let outcomeDescription: String
    public let evaluationMetricDescription: String
    
    public let goalsSupported: [Goal] // CCC, 3/29/2016. identifiers instead?
    
    public let reviews: [Review] // CCC, 3/29/2016. identifiers instead?
}


