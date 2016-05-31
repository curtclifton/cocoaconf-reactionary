//
//  QueueSpecificSignal.swift
//  SmartGoals
//
//  Created by Curt Clifton on 5/30/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation


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
    override func notifyObservers(ofValue value: Value) {
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
