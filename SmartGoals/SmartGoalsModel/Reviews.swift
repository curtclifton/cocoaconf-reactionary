//
//  Reviews.swift
//  SmartGoals
//
//  Created by Curt Clifton on 2/2/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation

public protocol Reviewable { // CCC, 3/29/2016. what should be Reviewable?
    var reviews: [Review] { get }
}

#error HERE is where you're working. 
// CCC, 3/29/2016. Add this to the model next.
public struct Review {
    let identifier: Identifier<Review>
    
    public let date: NSDate
    public let review: String
}
