//
//  SGMReview.swift
//  SmartGoals
//
//  Created by Curt Clifton on 4/5/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation
import CoreData


final class SGMReview: SGMIdentifiedObject {
}

extension SGMReview: ManagedObject {
    var identifier: Identifier<Review> {
        return Identifier(uuid: sgmIdentifier)
    }
}
