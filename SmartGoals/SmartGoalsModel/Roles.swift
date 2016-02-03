//
//  Roles.swift
//  SmartGoals
//
//  Created by Curt Clifton on 1/26/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation

public struct Role {
    let identifier: Identifier<Role>
    var explanation: String
    var shortName: String
    
    /// Indicates whether there are any goal sets associated with the Role.
    ///
    /// This is used to determine whether edits should to the other properties should cause the user to be prompted to create a new role or edit an existing role. If the role is not referenced, then edits can just edit the existing one without concern for unintended side effects.
    var isReferenced: Bool
    
    var isActive: Bool
}