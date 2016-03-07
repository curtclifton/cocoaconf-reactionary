//
//  Signal.swift
//  SmartGoals
//
//  Created by Curt Clifton on 2/14/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation
import CoreData

#error HERE is where you're working. 
// CCC, 3/2/2016. I'm not thrilled with this architecture. Better to have a single map function and add overloaded transform factories to Result. 
// CCC, 3/6/2016. Signal doesn't reference Result at all, it just has a Payload, which could be a result type, but doesn't have to be.
public class Signal<Value> {
    private(set) var currentResult: Result<Value>?
    var currentValue: Value? {
        if case let .value(currentValue)? = currentResult {
            return currentValue
        }
        return nil
    }
    private var observers: [Result<Value> -> ()] = []

    func updateToValue(value: Value) {
        updateToResult(.value(value))
    }
    
    func updateToError(error: ErrorType) {
        updateToResult(.error(error))
    }
    
    private func updateToResult(result: Result<Value>) {
        currentResult = result
        for observer in observers {
            observer(result)
        }
    }
    
    // CCC, 2/14/2016. Document capture pattern. Someone has to capture the root Signal or the whole chain will be deallocated. May want a different mapping function for the case where the observer and output signal should be held weakly.
    // Currently, clients must retain self directly or indirectly, or the signal chain will be deallocated.
    // capture pattern: self -> observer block -> outSignal and transform
    // Anything captured by the transform exists until self is deallocated!

    /// Calls the transform for all events.
    public func map<OutValue>(transform: Result<Value> -> Result<OutValue>) -> Signal<OutValue> {
        let outSignal: Signal<OutValue> = createOutSignal()
        
        let observer: Result<Value> -> () = { newResult in
            let outValue = transform(newResult)
            switch outValue {
            case .value(let value):
                outSignal.updateToValue(value)
            case .error(let error):
                outSignal.updateToError(error)
            }
        }
        
        addObserver(observer)
        return outSignal
    }
    
    /// Calls the transform for non-error events.
    ///
    /// The returned signal will only pass non-error events for which `transform` returns a non-nil value.
    public func valueOnlyMap<OutValue>(transform: Value -> OutValue?) -> Signal<OutValue> {
        let outSignal: Signal<OutValue> = createOutSignal()

        let observer: Result<Value> -> () = { newResult in
            switch newResult {
            case .value(let value):
                guard let outValue = transform(value) else { break }
                outSignal.updateToValue(outValue)
            case .error:
                // drop the event
                break
            }
        }

        addObserver(observer)
        return outSignal
    }

    /// Calls the handler for non-error events.
    ///
    /// For chaining, the returned signal is self.
    public func valuePassthroughHandler(handler: Value -> ()) -> Self {
        let observer: Result<Value> -> () = { newResult in
            switch newResult {
            case .value(let value):
                handler(value)
            case .error:
                // drop the event
                break
            }
        }
        
        addObserver(observer)
        return self
    }
    
    /// Calls the transform for non-error events.
    ///
    /// The returned signal will pass errors through unchanged.
    public func errorPassthroughMap<OutValue>(transform: Value -> Result<OutValue>) -> Signal<OutValue> {
        let outSignal: Signal<OutValue> = createOutSignal()
        
        let observer: Result<Value> -> () = { newResult in
            switch newResult {
            case .value(let value):
                let outResult = transform(value)
                outSignal.updateToResult(outResult)
            case .error(let error):
                outSignal.updateToError(error)
            }
        }
        
        addObserver(observer)
        return outSignal
    }
    
    /// Calls the transform for error events.
    ///
    /// The returned signal will pass success values through unchanged.
    public func errorHandlerMap(transform: ErrorType -> Result<Value>) -> Signal<Value> {
        let outSignal: Signal<Value> = createOutSignal()
        
        let observer: Result<Value> -> () = { newResult in
            switch newResult {
            case .value:
                outSignal.updateToResult(newResult)
            case .error(let error):
                let outResult = transform(error)
                outSignal.updateToResult(outResult)
            }
        }
        
        addObserver(observer)
        return outSignal
    }
    
    private func createOutSignal<OutValue>() -> Signal<OutValue> {
        return Signal<OutValue>()
    }
    
    private func addObserver(observer: Result<Value> -> ()) {
        observers.append(observer)
        if let existingResult = currentResult {
            observer(existingResult)
        }
    }
}

/// Instantiates a signal that executes `fetchRequest` in `context`, passing the fetched objects through `transform` and propagating the non-nil results on the signal. 
///
/// Expects 0 or 1 non-nil results for each fetch.
func itemFetchSignal<Value>(fetchRequest fetchRequest: NSFetchRequest, context: NSManagedObjectContext, transform: AnyObject -> Value?) -> FetchSignal<Value> {
    let result = FetchSignal<Value>(fetchRequest: fetchRequest, context: context) { (results: [AnyObject]) -> Value? in
        let typedMatches = results.flatMap { transform($0) }
        assert(typedMatches.count <= 1)
        if let match = typedMatches.first {
            return match
        }
        return nil
    }
    return result
}

/// Instantiates a signal that executes `fetchRequest` in `context`, passing the fetched objects through `transform` and propagating the non-nil results on the signal. 
/// 
/// If there are no non-nil results, will propagate an empty array if the context returns no matching results.
func arrayFetchSignal<Value>(fetchRequest fetchRequest: NSFetchRequest, context: NSManagedObjectContext, transform: AnyObject -> Value?) -> FetchSignal<[Value]> {
    let result = FetchSignal<[Value]>(fetchRequest: fetchRequest, context: context) { (results: [AnyObject]) -> [Value]? in
        let typedMatches = results.flatMap { transform($0) }
        return typedMatches
    }
    return result
}

final class FetchSignal<Value>: Signal<Value> {
    let fetchRequest: NSFetchRequest
    let context: NSManagedObjectContext
    let transform: [AnyObject] -> Value?
    
    /// Instantiates a signal that executes `fetchRequest` in `context`, passing the fetched objects through `transform` and propagating the result, if non-nil, on the signal.
    init(fetchRequest: NSFetchRequest, context: NSManagedObjectContext, transform: [AnyObject] -> Value?) {
        self.fetchRequest = fetchRequest
        self.context = context
        self.transform = transform
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "mocChanged:", name: NSManagedObjectContextObjectsDidChangeNotification, object: context)
        fetchUpdates()
    }
    
    private func anyEntityMatches(userInfo userInfo: [NSObject: AnyObject], key: String) -> Bool {
        guard let objects = userInfo[key] as? NSSet else { return false }
        for object in objects {
            if let managedObject = object as? NSManagedObject {
                let moEntityName = managedObject.entity.name
                let fetchEntityName = fetchRequest.entityName
                let fetchRequestPredicate = fetchRequest.predicate
                if moEntityName == fetchEntityName {
                    if let pred = fetchRequestPredicate {
                        if pred.evaluateWithObject(managedObject) {
                            return true
                        }
                    } else {
                        // if there's no predicate at all, update on a name match
                        return true
                    }
                }
            }
        }
        return false
    }
    
    @objc(mocChanged:)
    private func mocChanged(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        let matchFound = (anyEntityMatches(userInfo: userInfo, key: NSInsertedObjectsKey)
            || anyEntityMatches(userInfo: userInfo, key: NSDeletedObjectsKey)
            || anyEntityMatches(userInfo: userInfo, key: NSRefreshedObjectsKey)
            || anyEntityMatches(userInfo: userInfo, key: NSUpdatedObjectsKey))
        
        // CCC, 2/15/2016. Need to test the no-match-found path when we have another entity type
        if matchFound {
            fetchUpdates()
        }
    }
    
    private func fetchUpdates() {
        context.performBlock { [weak self] _ in
            guard let strongSelf = self else { return }
            do {
                let results = try strongSelf.context.executeFetchRequest(strongSelf.fetchRequest)
                let transformedResults = strongSelf.transform(results)
                if let transformedResults = transformedResults {
                    strongSelf.updateToValue(transformedResults)
                }
            } catch {
                strongSelf.updateToError(error)
            }
        }
    }
}
