//
//  TimeScale.swift
//  SmartGoals
//
//  Created by Curt Clifton on 2/2/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation

// CCC, 4/5/2016. Add to model
public struct TimeScale {
    let identifier: Identifier<TimeScale>
    
    public let description: String
    public let goalSets: [Identifier<GoalSet>]
}