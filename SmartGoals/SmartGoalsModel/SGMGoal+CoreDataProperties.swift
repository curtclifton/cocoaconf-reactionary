//
//  SGMGoal+CoreDataProperties.swift
//  SmartGoals
//
//  Created by Curt Clifton on 4/10/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension SGMGoal {

    @NSManaged var title: String?
    @NSManaged var outcomeDescription: String?
    @NSManaged var evaluationMetricDescription: String?
    @NSManaged var roleSupported: SGMRole?
    @NSManaged var goalsSupported: NSSet?
    @NSManaged var reviews: NSSet?

}
