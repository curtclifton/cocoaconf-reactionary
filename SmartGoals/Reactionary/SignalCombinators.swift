//
//  SignalCombinators.swift
//  SmartGoals
//
//  Created by Curt Clifton on 5/30/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation

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
