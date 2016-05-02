//
//  UITextViewExtensions.swift
//  SmartGoals
//
//  Created by Curt Clifton on 5/1/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation
import UIKit

extension UITextView: ReactiveControl {
    var monitoredControlEvents: UIControlEvents {
        return []
    }
    
    var reactiveValue: String {
        get {
            return self.text
        }
        set {
            if newValue != self.text {
                self.text = newValue
            }
        }
    }
    
    func addTarget(target: AnyObject?, action: Selector, forControlEvents controlEvents: UIControlEvents) {
        // UITextView is not a UIControl, so we implement the addTarget method to observe self
        precondition(controlEvents == monitoredControlEvents)
        NSNotificationCenter.defaultCenter().addObserverForName(UITextViewTextDidChangeNotification, object: self, queue: nil) { notification in
            target?.performSelector(action)
        }
    }
}