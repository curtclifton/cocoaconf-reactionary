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

struct RoleViewModel: TableViewCellModel {
    let text: String?
    let detailText: String?
    let textPlaceholder: String? = NSLocalizedString("untitled role", comment: "placeholder text")
    let detailTextPlaceholder: String? = " " // non-empty string to consume vertical space
    
    init(_ role: Role) {
        self.text = role.shortName
        self.detailText = role.explanation
    }
}

extension Role {
    var viewModel: RoleViewModel {
        return RoleViewModel(self)
    }
}