//
//  SGMRole+CoreDataProperties.swift
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

extension SGMRole {

    @NSManaged var explanation: String?
    @NSManaged var isActive: Bool
    @NSManaged var shortName: String?

}
