//
//  SGMGoal+CoreDataProperties.swift
//  SmartGoals
//
//  Created by Curt Clifton on 4/24/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension SGMGoal {

    @NSManaged var evaluationMetricDescription: String?
    @NSManaged var goalsSupportedIDs: NSObject?
    @NSManaged var outcomeDescription: String?
    @NSManaged var reviewsIDs: NSObject?
    @NSManaged var roleSupportedID: Int64
    @NSManaged var title: String?

}
