//
//  SGMGoalSet+CoreDataProperties.swift
//  SmartGoals
//
//  Created by Curt Clifton on 4/19/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension SGMGoalSet {

    @NSManaged var targetDate: NSTimeInterval
    @NSManaged var goalsIDs: NSObject?
    @NSManaged var reviewsIDs: NSObject?
    @NSManaged var rolesIDs: NSObject?
    @NSManaged var timeScaleID: Int64

}
