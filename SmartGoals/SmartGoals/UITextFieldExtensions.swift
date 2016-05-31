//
//  UITextFieldExtensions.swift
//  SmartGoals
//
//  Created by Curt Clifton on 5/1/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation
import Reactionary
import SmartGoalsModelTouch
import UIKit

// We just use the addresses of these to bridge to the C API for associated objects:
private var setterSignalKey: UInt8 = 0
private var valueChangedSignalKey: UInt8 = 0

extension UITextField: ReactiveControl {
    var monitoredControlEvents: UIControlEvents {
        return .EditingChanged
    }

    var reactiveValue: String {
        get {
            return text ?? ""
        }
        set {
            if newValue != text {
                text = newValue
            }
        }
    }
}
