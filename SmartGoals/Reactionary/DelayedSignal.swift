//
//  DelayedSignal.swift
//  SmartGoals
//
//  Created by Curt Clifton on 5/30/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation

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

