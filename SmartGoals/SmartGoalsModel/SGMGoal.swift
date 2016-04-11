//
//  SGMGoal.swift
//  SmartGoals
//
//  Created by Curt Clifton on 4/10/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation
import CoreData


final class SGMGoal: SGMIdentifiedObject {
}

extension SGMGoal: ManagedObject {
    var identifier: Identifier<Goal> {
        return Identifier(uuid: sgmIdentifier)
    }
}