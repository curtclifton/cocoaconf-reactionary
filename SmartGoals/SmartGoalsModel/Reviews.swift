//
//  Reviews.swift
//  SmartGoals
//
//  Created by Curt Clifton on 2/2/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation
import CoreData

public protocol Reviewable {
    var reviews: [Identifier<Review>] { get }
}

extension SGMReview: ModelValueUpdatable {
    func updateFromValue<Value : ModelValue>(value: Value) {
        guard let review = value as? Review else {
            fatalError("Attempting to update SGMReview from non-Review value: \(value)")
        }
        precondition(self.sgmIdentifier == review.identifier.uuid)

        self.date = review.date.timeIntervalSinceReferenceDate
        self.review = review.review
    }
}

public struct Review: ModelValue {
    public static var entityName: String {
        return SGMReview.entityName
    }
    
    public static var fetchRequest: NSFetchRequest {
        return SGMReview.fetchRequest()
    }
    
    public let identifier: Identifier<Review>
    
    public var date: NSDate
    public var review: String
    
    public init?(fromObject: AnyObject) {
        guard let object = fromObject as? SGMReview else {
            return nil
        }
        self.identifier = object.identifier
        self.date = NSDate(timeIntervalSinceReferenceDate: object.date)
        self.review = object.review ?? ""
    }
}
