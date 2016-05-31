//
//  OneShotSignal.swift
//  SmartGoals
//
//  Created by Curt Clifton on 5/30/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation


/// A signal that notifies its observers exactly once, releasing them after notifying.
///
/// A `OneShotSignal` retains its source signal so that clients need only retain the `OneShotSignal` itself.
public final class OneShotSignal<Value>: Signal<Value> {
    public let source: Signal<Value>
    private var transform: TransformID? // must be an optional var so we can use `self` in definition
    
    private init(signal: Signal<Value>) {
        self.source = signal
        super.init()
        
        transform = signal.weakProxy.addObserver { [weak self] value in
            self?.update(toValue: value)
        }
    }
    
    /// Override to clear `observers` after notifying.
    override func notifyObservers(ofValue value: Value) {
        for observer in observers {
            observer(value)
        }
        observers = []
    }
    
    /// Override to suppress caching of `observer` if we have a value with which to notify it already.
    override func addObserver(observer: Value -> ()) {
        if let existingValue = currentValue {
            observer(existingValue)
        } else {
            observers.append(observer)
        }
    }
    
    public var isPrimed: Bool {
        return currentValue != nil
    }
}

extension Signal {
    public func oneShotSignal() -> OneShotSignal<Value> {
        let result = OneShotSignal(signal: self)
        return result
    }
}

extension OneShotSignal: SourceAwareSignal, QueueAwareSignal {
}