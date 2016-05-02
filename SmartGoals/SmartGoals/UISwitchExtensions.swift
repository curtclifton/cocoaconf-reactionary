//
//  UISwitchExtensions.swift
//  SmartGoals
//
//  Created by Curt Clifton on 5/1/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation
import UIKit

extension UISwitch: ReactiveControl {
    var monitoredControlEvents: UIControlEvents {
        return .ValueChanged
    }
    
    var reactiveValue: Bool {
        get {
            return self.on
        }
        set {
            if newValue != self.on {
                self.on = newValue
            }
        }
    }
}