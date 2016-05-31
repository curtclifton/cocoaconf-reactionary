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
    
    private var observers: [Value -> ()] = []
    
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

    private func notifyObservers(ofValue value: Value) {
        for observer in observers {
            observer(value)
        }
    }
    
    private func addObserver(observer: Value -> ()) {
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
    weak private var signal: Signal<Value>?
    
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
    
    private func addObserver(observer: Value -> ()) -> WeakTransform<Value> {
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
/// This is a private subclass so we can hide the generic `Value`.
private final class WeakTransform<Value>: TransformID {
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

// MARK: - Queues

protocol QueueAwareSignal {
    var queueForNotifications: NSOperationQueue? { get }
}

// Default implementation that walks source chain. QueueSpecificSignal has its own implementation that just returns the queue.
extension QueueAwareSignal where Self: SourceAwareSignal {
    var queueForNotifications: NSOperationQueue? {
        let source = self.source
        if let queueAwareSource = source as? QueueAwareSignal {
            return queueAwareSource.queueForNotifications
        }
        return nil
    }
}

extension MapOutputSignal: QueueAwareSignal {
    var queueForNotifications: NSOperationQueue? {
        if let queueAwareSource = observed as? QueueAwareSignal {
            return queueAwareSource.queueForNotifications
        }
        return nil
    }
}

extension WeakProxySignal: QueueAwareSignal {
    var queueForNotifications: NSOperationQueue? {
        if let queueAwareSource = signal as? QueueAwareSignal {
            return queueAwareSource.queueForNotifications
        }
        return nil
    }
}

/// A signal that notifies its observer on a specific queue.
///
/// A `QueueSpecificSignal` retains its source signal so that clients need only retain the `QueueSpecificSignal` itself.
public class QueueSpecificSignal<Value>: Signal<Value> {
    public let source: Signal<Value>
    private let queue: NSOperationQueue
    private var transform: TransformID? // must be an optional var so we can use `self` in definition
    
    private init(signal: Signal<Value>, notificationQueue: NSOperationQueue) {
        self.source = signal
        self.queue = notificationQueue
        super.init()
        
        self.transform = signal.weakProxy.addObserver { [weak self] value in
            self?.update(toValue: value)
        }
    }
    
    /// Overrides `notifyObservers(ofValue:)` to push notifications on `notificationQueue`.
    override private func notifyObservers(ofValue value: Value) {
        let observers = self.observers
        queue.addOperationWithBlock { 
            for observer in observers {
                observer(value)
            }
        }
    }
}

extension Signal {
    public func signal(onQueue queue: NSOperationQueue) -> Signal<Value> {
        if let queueAwareSelf = self as? QueueAwareSignal where queueAwareSelf.queueForNotifications === queue {
            return self
        }

        let result = QueueSpecificSignal(signal: self, notificationQueue: queue)
        return result
    }
}

extension QueueSpecificSignal: QueueAwareSignal {
    var queueForNotifications: NSOperationQueue? {
        return queue
    }
}

extension QueueSpecificSignal: SourceAwareSignal {
}

// MARK: - One Shots

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
    override private func notifyObservers(ofValue value: Value) {
        for observer in observers {
            observer(value)
        }
        observers = []
    }
    
    /// Override to suppress caching of `observer` if we have a value with which to notify it already.
    override private func addObserver(observer: Value -> ()) {
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


// MARK: - Delays

public final class DelayedSignal<Value>: Signal<Value> {
    public let source: Signal<Value>
    private let delayInNanoseconds: Int64
    private var transform: TransformID? // must be an optional var so we can use `self` in definition
    
    private init(signal: Signal<Value>, delay: NSTimeInterval) {
        self.source = signal
        self.delayInNanoseconds = Int64(round(delay * 1_000_000_000))
        super.init()
        
        transform = signal.weakProxy.addObserver { [weak self] newValue in
            guard let strongSelf = self else { return }
            let propagateTime = dispatch_time(0, strongSelf.delayInNanoseconds)
            let queue = dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)
            dispatch_after(propagateTime, queue) {
                self?.update(toValue: newValue) // intentionally using weak self again
            }
        }
    }
}

extension Signal {
    public func signal(withDelay delay: NSTimeInterval) -> DelayedSignal<Value> {
        let result = DelayedSignal(signal: self, delay: delay)
        return result
    }
}

extension DelayedSignal: SourceAwareSignal, QueueAwareSignal {
}

// MARK: - Combinators

public final class Zip2Signal<InValue1, InValue2>: Signal<(InValue1?, InValue2?)> {
    private let signal1: Signal<InValue1>
    private let signal2: Signal<InValue2>
    private var transforms: [TransformID] = [] // must be a var so we can use `self` in definitions

    private init(signal1: Signal<InValue1>, signal2: Signal<InValue2>) {
        self.signal1 = signal1
        self.signal2 = signal2
        super.init()
        
        transforms.append(signal1.weakProxy.addObserver { [weak self] value1 in
            guard let strongSelf = self else { return }
            strongSelf.update(toValue: (value1, strongSelf.signal2.currentValue))
        })
        
        transforms.append(signal2.weakProxy.addObserver { [weak self] value2 in
            guard let strongSelf = self else { return }
            strongSelf.update(toValue: (strongSelf.signal1.currentValue, value2))
        })
    }
}

public final class Zip3Signal<InValue1, InValue2, InValue3>: Signal<(InValue1?, InValue2?, InValue3?)> {
    private let signal1: Signal<InValue1>
    private let signal2: Signal<InValue2>
    private let signal3: Signal<InValue3>
    private var transforms: [TransformID] = [] // must be a var so we can use `self` in definitions

    private init(signal1: Signal<InValue1>, signal2: Signal<InValue2>, signal3: Signal<InValue3>) {
        self.signal1 = signal1
        self.signal2 = signal2
        self.signal3 = signal3
        super.init()
        
        transforms.append(signal1.weakProxy.addObserver { [weak self] value1 in
            guard let strongSelf = self else { return }
            strongSelf.update(toValue: (value1, strongSelf.signal2.currentValue, strongSelf.signal3.currentValue))
        })
        
        transforms.append(signal2.weakProxy.addObserver { [weak self] value2 in
            guard let strongSelf = self else { return }
            strongSelf.update(toValue: (strongSelf.signal1.currentValue, value2, strongSelf.signal3.currentValue))
        })
        
        transforms.append(signal3.weakProxy.addObserver { [weak self] value3 in
            guard let strongSelf = self else { return }
            strongSelf.update(toValue: (strongSelf.signal1.currentValue, strongSelf.signal2.currentValue, value3))
        })
    }
}

extension Signal {
    public func signal<Value2>(zippingWith other: Signal<Value2>) -> Zip2Signal<Value, Value2> {
        let result = Zip2Signal(signal1: self, signal2: other)
        return result
    }

    public func signal<Value2, Value3>(zippingWith other2: Signal<Value2>, and other3: Signal<Value3>) -> Zip3Signal<Value, Value2, Value3> {
        let result = Zip3Signal(signal1: self, signal2: other2, signal3: other3)
        return result
    }
}
