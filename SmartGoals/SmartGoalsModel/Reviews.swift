//
//  Reviews.swift
//  SmartGoals
//
//  Created by Curt Clifton on 2/2/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation

public protocol Reviewable {
    var reviews: [Review] { get }
}

public struct Review {
    let identifier: Identifier<Review>
    
    public let date: NSDate
    public let review: String
}
