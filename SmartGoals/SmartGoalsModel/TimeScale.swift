//
//  TimeScale.swift
//  SmartGoals
//
//  Created by Curt Clifton on 2/2/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation

struct TimeScale {
    let identifier: Identifier<TimeScale>
    let description: String
    
    let goalSets: [GoalSet]
}