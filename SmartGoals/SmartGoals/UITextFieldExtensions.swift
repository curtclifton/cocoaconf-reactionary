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

// CCC, 5/1/2016. Use conformance to ReactiveControl instead
extension UITextField {
    func takeValue(fromSignal signal: Signal<String>) {
        let mainThreadSignal = QueueSpecificSignal(signal: signal, notificationQueue: NSOperationQueue.mainQueue())
        // Need to hang onto the signal so it isn't deallocated
        objc_setAssociatedObject(self, &setterSignalKey, mainThreadSignal, .OBJC_ASSOCIATION_RETAIN)
        mainThreadSignal.map { [weak self] (value: String) -> Void in
            if self?.text != value {
                self?.text = value
            }
        }
    }
    
    private var _valueChangedSignal: UpdatableSignal<String?>? {
        get {
            guard let existingSignal = objc_getAssociatedObject(self, &valueChangedSignalKey) as? UpdatableSignal<String?> else {
                return nil
            }
            return existingSignal
        }
        set {
            objc_setAssociatedObject(self, &valueChangedSignalKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func valueChangedSignal() -> Signal<String?> {
        if let existingSignal = _valueChangedSignal {
            return existingSignal
        }
        let signal = UpdatableSignal<String?>()
        _valueChangedSignal = signal
        addTarget(self, action: #selector(valueChanged), forControlEvents: .EditingChanged)
        return signal
    }
    
    dynamic private func valueChanged() {
        guard let signal = _valueChangedSignal else {
            fatalError("how did we register an action without storing a signal?")
        }
        
        signal.update(toValue: self.text)
    }
}
