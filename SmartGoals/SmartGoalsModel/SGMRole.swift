//
//  SGMRole.swift
//  SmartGoals
//
//  Created by Curt Clifton on 2/13/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation
import CoreData


final class SGMRole: SGMIdentifiedObject {
}

extension SGMRole: ManagedObject {
    var identifier: Identifier<Role> {
        return Identifier(uuid: sgmIdentifier)
    }
}
