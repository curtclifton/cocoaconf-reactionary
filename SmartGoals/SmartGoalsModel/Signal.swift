//
//  Signal.swift
//  SmartGoals
//
//  Created by Curt Clifton on 2/14/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation

// CCC, 5/15/2016. Split out Signal subclasses. Make most functions internal, since we have our own module for these now.

/// A mappable signal producing values of type `Value`.
///
/// In general, clients must retain instances of `Signal` except as documented. The basic capture pattern is that a signal captures the blocks passed to `map` and `flatmap`. The new signal returned from an invocation of either mapping function is also retained by the original signal.
///
/// Clients wishing to unsubscribe from a signal should instead subscribe to the signal's `weakProxy`.
///
/// N.B., anything captured by a block passed to `map` and `flatmap` will be retained until the `Signal` is released. Capturing strong `self` in one of these blocks is a great way to created a retain cycle.
public class Signal<Value> {

    public private(set) var currentValue: Value?
    
    /// Returns the weak proxy object for this signal.
    ///
    /// - SeeAlso: `WeakProxySignal`
    public lazy var weakProxy: WeakProxySignal<Value> = WeakProxySignal<Value>(signal: self)
    
    /// Internal for subclass access.
    var observers: [Value -> ()] = []
    
    /// Pushes a new value on the signal.
    ///
    /// This is internal so subclasses can prevent clients from pushing signals. Clients wishing to push signals should use `UpdatableSignal`.
    func update(toValue value: Value) {
        currentValue = value
        notifyObservers(ofValue: value)
    }
    
    /// Calls `transform` for all events, pushing the result on the returned signal.
    public func map<OutValue>(transform: Value -> OutValue) -> Signal<OutValue> {
        let outSignal = MapOutputSignal<Value, OutValue>(observing: self)
        
        let observer: Value -> () = { newValue in
            let outValue = transform(newValue)
            outSignal.update(toValue: outValue)
        }
        
        addObserver(observer)
        return outSignal
    }
    
    /// Calls `transform` for all events, pushing the non-nil results on the returned signal.
    public func flatmap<OutValue>(transform: Value -> OutValue?) -> Signal<OutValue> {
        let outSignal = MapOutputSignal<Value, OutValue>(observing: self)
        
        let observer: Value -> () = { newValue in
            if let outValue = transform(newValue) {
                outSignal.update(toValue: outValue)
            }
        }
        
        addObserver(observer)
        return outSignal
    }

    //MARK: Subclass API

    func notifyObservers(ofValue value: Value) {
        for observer in observers {
            observer(value)
        }
    }
    
    func addObserver(observer: Value -> ()) {
        observers.append(observer)
        if let existingValue = currentValue {
            observer(existingValue)
        }
    }
}

/// A signal to which client code can push new values.
public class UpdatableSignal<Value>: Signal<Value> {
    public convenience init(withInitialValue value: Value) {
        self.init()
        update(toValue: value)
    }
    
    public override init() {
        super.init()
    }
    
    public override func update(toValue value: Value) {
        super.update(toValue: value)
    }
}

protocol SourceAwareSignal {
    associatedtype Value
    var source: Signal<Value> { get }
}

final class MapOutputSignal<InValue, Value>: Signal<Value> {
    weak var observed: Signal<InValue>?
    
    required init(observing observed: Signal<InValue>) {
        self.observed = observed
        super.init()
    }
}
