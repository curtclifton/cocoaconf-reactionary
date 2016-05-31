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

// MARK: - Reference Management

/// A signal-like class that supports unsubscribing.
///
/// Instances of this are obtained via the `weakProxy` property of true `Signal`s.
public final class WeakProxySignal<Value> {
    public private(set) var currentValue: Value?
    private var wrappedTransforms: [WeakWrapper<WeakTransform<Value>>] = []
    weak var signal: Signal<Value>?
    
    private init(signal: Signal<Value>) {
        // OK to capture self here. The underlying signal keeps us alive, but we don't keep a strong pointer to it.
        signal.map { value in
            self.currentValue = value
            self.notifyObservers(ofValue: value)
        }
        self.signal = signal
    }

    /// Calls `transform` for all events, pushing the result on the returned signal.
    ///
    /// Callers must ensure that they retain a reference to the returned `TransformID` object as long as they wish to subscribe to the receiver. The `transform` function will cease to be called sometime after the last reference to the returned `TransformID` is nilled. Because of the vagaries of memory management, this may not happen immediately.
    public func map<OutValue>(transform: Value -> OutValue) -> (TransformID, Signal<OutValue>) {
        let outSignal = Signal<OutValue>()
        
        let observer: Value -> () = { newValue in
            let outValue = transform(newValue)
            outSignal.update(toValue: outValue)
        }
        
        let transform = addObserver(observer)
        return (transform, outSignal)
    }
    
    /// Calls `transform` for all events, pushing the non-nil results on the returned signal.
    ///
    /// Callers must ensure that they retain a reference to the returned `TransformID` object as long as they wish to subscribe to the receiver. The `transform` function will cease to be called sometime after the last reference to the returned `TransformID` is nilled. Because of the vagaries of memory management, this may not happen immediately.
    public func flatmap<OutValue>(transform: Value -> OutValue?) -> (TransformID, Signal<OutValue>) {
        let outSignal = Signal<OutValue>()
        
        let observer: Value -> () = { newValue in
            if let outValue = transform(newValue) {
                outSignal.update(toValue: outValue)
            }
        }
        
        let transform = addObserver(observer)
        return (transform, outSignal)
    }
    
    private func notifyObservers(ofValue value: Value) {
        let observers = wrappedTransforms.flatMap { wrapper in wrapper.value?.observer }
        for observer in observers {
            observer(value)
        }
    }
    
    /// Internal so Signal subclasses can invoke.
    func addObserver(observer: Value -> ()) -> WeakTransform<Value> {
        let result = WeakTransform(weakProxy: self, observer: observer)
        let wrapped = WeakWrapper(result)
        wrappedTransforms.append(wrapped)
        if let existingValue = currentValue {
            observer(existingValue)
        }
        return result
    }

    /// Called by `WeakTransform`'s `deinit`.
    private func cleanTransforms() {
        wrappedTransforms = wrappedTransforms.filter { wrapper in !wrapper.isEmptied }
    }
}

/// This opaque class is returned by the map functions on a signal's `weakProxy`.
///
/// It is used to keep a transform applied to a signal's `weakProxy` alive. A client maintains its subscription to the signal by keeping a reference to the returned `WeakTransform`. The client can unsubscribe from the signal by releasing the corresponding `WeakTransform`.
public class TransformID {
}

/// The actual class we used to allow weak references to the observer blocks.
///
/// This is an internal subclass so we can hide the generic `Value`.
final class WeakTransform<Value>: TransformID {
    weak var weakProxy: WeakProxySignal<Value>?
    let observer: (Value) -> Void
    
    init(weakProxy: WeakProxySignal<Value>, observer: (Value) -> Void) {
        self.weakProxy = weakProxy
        self.observer = observer
    }
    
    deinit {
        weakProxy?.cleanTransforms()
    }
}

/// A utility wrapper class so we can put weak references inside Swift arrays with strong typing.
private final class WeakWrapper<Wrapped: AnyObject> {
    weak var value: Wrapped?
    var isEmptied: Bool {
        return value == nil
    }
    init(_ value: Wrapped) {
        self.value = value
    }
}
