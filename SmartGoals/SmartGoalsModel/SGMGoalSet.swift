//
//  SGMGoalSet.swift
//  SmartGoals
//
//  Created by Curt Clifton on 4/10/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation
import CoreData


final class SGMGoalSet: SGMIdentifiedObject {
}

extension SGMGoalSet: ManagedObject {
    var identifier: Identifier<GoalSet> {
        return Identifier(uuid: sgmIdentifier)
    }
}