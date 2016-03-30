//
//  Signal.swift
//  SmartGoals
//
//  Created by Curt Clifton on 2/14/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation
import CoreData


// CCC, 2/14/2016. Document capture pattern. Someone has to capture the root Signal or the whole chain will be deallocated. May want a different mapping function for the case where the observer and output signal should be held weakly.
// Currently, clients must retain self directly or indirectly, or the signal chain will be deallocated.
// capture pattern: self -> observer block -> outSignal and transform
// Anything captured by the transform exists until self is deallocated!

public class Signal<Value> {

    private(set) var currentValue: Value?
    private var observers: [Value -> ()] = []
    
    /// Pushes a new value on the signal.
    ///
    /// This is private so subclasses can prevent clients from pushes signals. Clients wishing to push signals should use `UpdatableSignal`.
    private func update(toValue value: Value) {
        currentValue = value
        for observer in observers {
            observer(value)
        }
    }
    
    /// Calls `transform` for all events, pushing the result on the returned signal.
    public func map<OutValue>(transform: Value -> OutValue) -> Signal<OutValue> {
        let outSignal: Signal<OutValue> = createOutSignal()
        
        let observer: Value -> () = { newValue in
            let outValue = transform(newValue)
            outSignal.update(toValue: outValue)
        }
        
        addObserver(observer)
        return outSignal
    }
    
    /// Calls `transform` for all events, pushing the non-nil results on the returned signal.
    public func flatmap<OutValue>(transform: Value -> OutValue?) -> Signal<OutValue> {
        let outSignal: Signal<OutValue> = createOutSignal()
        
        let observer: Value -> () = { newValue in
            if let outValue = transform(newValue) {
                outSignal.update(toValue: outValue)
            }
        }
        
        addObserver(observer)
        return outSignal
    }

    //MARK: Private API
    
    private func createOutSignal<OutValue>() -> Signal<OutValue> {
        return Signal<OutValue>()
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
    public override func update(toValue value: Value) {
        super.update(toValue: value)
    }
}

/// Instantiates a signal that executes `fetchRequest` in `context`, passing the fetched objects through `transform` and propagating the non-nil results on the signal.
///
/// Expects 0 or 1 non-nil results for each fetch.
func itemFetchSignal<Value>(fetchRequest fetchRequest: NSFetchRequest, context: NSManagedObjectContext, transform: AnyObject -> Value?) -> FetchSignal<Value> {
    let signal = FetchSignal<Value>(fetchRequest: fetchRequest, context: context) { (results: [AnyObject]) -> Value? in
        let typedMatches = results.flatMap { transform($0) }
        assert(typedMatches.count <= 1)
        if let match = typedMatches.first {
            return match
        }
        return nil
    }
    return signal
}

/// Instantiates a signal that executes `fetchRequest` in `context`, passing the fetched objects through `transform` and propagating the non-nil results on the signal. 
/// 
/// If there are no non-nil results, will propagate an empty array if the context returns no matching results.
func arrayFetchSignal<Value>(fetchRequest fetchRequest: NSFetchRequest, context: NSManagedObjectContext, transform: AnyObject -> Value?) -> FetchSignal<[Value]> {
    let signal = FetchSignal<[Value]>(fetchRequest: fetchRequest, context: context) { (results: [AnyObject]) -> [Value]? in
        let typedMatches = results.flatMap { transform($0) }
        return typedMatches
    }
    return signal
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FetchSignal.mocChanged(_:)), name: NSManagedObjectContextObjectsDidChangeNotification, object: context)
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
                let fetchResults = try strongSelf.context.executeFetchRequest(strongSelf.fetchRequest)
                let transformedResult = strongSelf.transform(fetchResults)
                if let transformedResult = transformedResult {
                    strongSelf.update(toValue: transformedResult)
                }
            } catch {
                fatalError("Error running fetch request: \(error)")
            }
        }
    }
}
