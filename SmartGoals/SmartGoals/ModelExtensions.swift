//
//  ModelExtensions.swift
//  SmartGoals
//
//  Created by Curt Clifton on 4/24/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation
import SmartGoalsModelTouch

extension TimeScale {
    var title: String {
        switch self {
        case .FiveYear:
            return NSLocalizedString("5 Year", comment: "goal set interval")
        case .OneYear:
            return NSLocalizedString("1 Year", comment: "goal set interval")
        case .Monthly:
            return NSLocalizedString("Monthly", comment: "goal set interval")
        }
    }
}

