//
//  SGMTimeScale.swift
//  SmartGoals
//
//  Created by Curt Clifton on 4/10/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation
import CoreData


final class SGMTimeScale: SGMIdentifiedObject {
}

extension SGMTimeScale: ManagedObject {
    var identifier: Identifier<TimeScale> {
        return Identifier(uuid: sgmIdentifier)
    }
}