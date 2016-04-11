//
//  Roles.swift
//  SmartGoals
//
//  Created by Curt Clifton on 1/26/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation
import CoreData

extension SGMRole: ModelValueUpdatable {
    func updateFromValue<Value : ModelValue>(value: Value) {
        guard let role = value as? Role else {
            fatalError("Attempting to update SGMRole from non-Role value: \(value)")
        }
        self.explanation = role.explanation
        self.shortName = role.shortName
        self.isActive = role.isActive
    }
}

public struct Role: ModelValue {
    public static var entityName: String {
        return SGMRole.entityName
    }

    public static var fetchRequest: NSFetchRequest {
        return SGMRole.fetchRequest()
    }
    
    public let identifier: Identifier<Role>
    
    public var explanation: String
    public var shortName: String
    
    /// Indicates whether there are any goal sets associated with the Role.
    ///
    /// This is used to determine whether edits should to the other properties should cause the user to be prompted to create a new role or edit an existing role. If the role is not referenced, then edits can just edit the existing one without concern for unintended side effects.
    public var isReferenced: Bool {
        // CCC, 2/15/2016. This should probably be a computed property based on a database fetch against goal sets
        return false
    }
    
    public var isActive: Bool

    public init?(fromObject: AnyObject) {
        guard let object = fromObject as? SGMRole else {
            return nil
        }
        self.identifier = object.identifier
        self.explanation = object.explanation ?? ""
        self.shortName = object.shortName ?? ""
        self.isActive = object.isActive
    }
}
