//
//  Identifier.swift
//  SmartGoals
//
//  Created by Curt Clifton on 2/13/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation

public struct Identifier<Identified> {
    let uuid: Int64
    
    var predicate: NSPredicate {
        NSStringFromSelector("sgmIdentifier")
        return NSPredicate(format: "%K == %@", argumentArray: [NSStringFromSelector("sgmIdentifier"), NSNumber(longLong: uuid)])
    }
    
    init() {
        var bytes = Array<UInt8>(count: 8, repeatedValue: 0)
        let success = SecRandomCopyBytes(kSecRandomDefault, 8, &bytes)
        assert(success == 0, "always expect to be able to create random bytes")
        var val: UInt64 = 0
        for byte in bytes {
            val = (val << 8) + UInt64(byte)
        }
        uuid = Int64(bitPattern: val)
    }
    
    init(uuid: Int64) {
        self.uuid = uuid
    }
}

extension Identifier: CustomStringConvertible {
    public var description: String {
        return String(uuid, radix: 16)
    }
}

extension Identifier: Equatable {}
public func ==<Identified>(lhs: Identifier<Identified>, rhs: Identifier<Identified>) -> Bool {
    return lhs.uuid == rhs.uuid
}
