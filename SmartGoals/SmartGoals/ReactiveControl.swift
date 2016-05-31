//
//  ReactiveControl
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
private var dynamicTargetKey: UInt8 = 0

/// Protocol that can be adopted by `UIControl`s via extensions to make them take and vend reactive signals.
protocol ReactiveControl: class {
    /// The type of the vended by the signals for this control.
    associatedtype Value: Equatable
    
    /// The control events that cause the `valueChangedSignal()` to fire.
    var monitoredControlEvents: UIControlEvents { get }
    
    /// Tells this control to update in response to values vended by the given signal.
    func takeValue(fromSignal signal: Signal<Value>)
    
    /// Returns a signal that will vend values in response to the changing state of the control.
    func valueChangedSignal() -> Signal<Value>
    
    /// Cover property for the control's value.
    ///
    /// For example, for a `UISwitch` the getter and setter for this property would cover the switch's `on` property.
    var reactiveValue: Value { get set }
    
    /// Redeclaration of the method from `UIControl`.
    ///
    /// `UIControl` subclasses conforming to `ReactiveControl` get this method for free by inheriting it. It's declared here so that types that don't subclass `UIControl` can also benefit from the default implementation of `valueChangedSignal()`.
    func addTarget(target: AnyObject?, action: Selector, forControlEvents controlEvents: UIControlEvents)
}

extension ReactiveControl {
    private var _valueChangedSignal: UpdatableSignal<Value>? {
        get {
            guard let existingSignal = objc_getAssociatedObject(self, &valueChangedSignalKey) as? UpdatableSignal<Value> else {
                return nil
            }
            return existingSignal
        }
        set {
            objc_setAssociatedObject(self, &valueChangedSignalKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    func takeValue(fromSignal signal: Signal<Value>) {
        let mainThreadSignal = signal.signal(onQueue: .mainQueue())
        // Need to hang onto the signal so it isn't deallocated
        objc_setAssociatedObject(self, &setterSignalKey, mainThreadSignal, .OBJC_ASSOCIATION_RETAIN)
        mainThreadSignal.map { [weak self] (value: Value) -> Void in
            if self?.reactiveValue != value {
                self?.reactiveValue = value
            }
        }
    }
    
    func valueChangedSignal() -> Signal<Value> {
        if let existingSignal = _valueChangedSignal {
            return existingSignal
        }
        
        // no stored signal, so make one
        let signal = UpdatableSignal<Value>()
        _valueChangedSignal = signal
        let dynamicTarget = DynamicTarget(self)
        // keep dynamic target from being dealloc'd
        objc_setAssociatedObject(self, &dynamicTargetKey, dynamicTarget, .OBJC_ASSOCIATION_RETAIN)
        let sel = #selector(dynamicTarget.valueChanged)
        addTarget(dynamicTarget, action: sel, forControlEvents: monitoredControlEvents)
        return signal
    }
}

/// A shim to work around limitations of Swift protocols.
///
/// A default method implementation for a protocol can't make a UIControl target itself. We bounce through a `DynamicTarget` instance instead.
class DynamicTarget<RealTarget: ReactiveControl>: NSObject {
    weak var realTarget: RealTarget?
    
    init(_ realTarget: RealTarget) {
        self.realTarget = realTarget
    }
    
    dynamic private func valueChanged() {
        guard let realTarget = realTarget else {
            // realTarget dealloc'd
            return
        }
        
        guard let signal = realTarget._valueChangedSignal else {
            fatalError("how did we register an action without storing a signal?")
        }
        
        signal.update(toValue: realTarget.reactiveValue)
    }
}
