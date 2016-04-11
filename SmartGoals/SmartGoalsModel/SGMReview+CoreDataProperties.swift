//
//  SGMReview+CoreDataProperties.swift
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

extension SGMReview {

    @NSManaged var date: NSTimeInterval
    @NSManaged var review: String?

}
