//
//  CoreDataAdapters.swift
//  SmartGoals
//
//  Created by Curt Clifton on 2/13/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation
import CoreData

final class SmartGoalsManagedObjectContext: NSManagedObjectContext {
    /// Creates a main MOC and associated SQL CoreData stack.
    convenience init(storeLocation: NSURL, name: String) {
        self.init(possibleStoreLocation: storeLocation, name: name)
    }
    
    /// Creates a main MOC and associated CoreData stack in memory.
    convenience init(name: String) {
        self.init(possibleStoreLocation: nil, name: name)
    }
    
    /// Creates a child MOC of `parentMOC`.
    init(name: String, parentMOC: SmartGoalsManagedObjectContext) {
        super.init(concurrencyType: .PrivateQueueConcurrencyType)
        self.name = name
        self.parentContext = parentMOC
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("use init(storeLocation:, name:) instead")
    }
    
    private init(possibleStoreLocation storeLocation: NSURL?, name: String) {
        super.init(concurrencyType: .PrivateQueueConcurrencyType)
        self.name = name
        
        do {
            let model = self.model()
            let persistentStoreCoordinator = try self.persistentStoreCoordinator(forModel:model, storeLocation: storeLocation)
            self.persistentStoreCoordinator = persistentStoreCoordinator
        } catch {
            fatalError("error initializing CoreData stack: \(error)")
        }
    }
    
    let modelName = "Model"
    
    //MARK: - Private API
    
    //MARK: Stack Construction
    private var modelBundle: NSBundle {
        let cls = self.dynamicType
        let result = NSBundle(forClass: cls)
        return result
    }
    
    private func model() -> NSManagedObjectModel {
        let maybeModelLocation = modelBundle.URLForResource(modelName, withExtension: "momd")
        guard let modelLocation = maybeModelLocation else {
            fatalError("Unable to find model definition")
        }
        let maybeModel = NSManagedObjectModel(contentsOfURL: modelLocation)
        guard let model = maybeModel else {
            fatalError("Unable to load your MOM")
        }
        return model
    }
    
    private func persistentStoreCoordinator(forModel model: NSManagedObjectModel, storeLocation: NSURL?) throws -> NSPersistentStoreCoordinator {
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        let storeKind = (storeLocation == nil ? NSInMemoryStoreType : NSSQLiteStoreType)
        try persistentStoreCoordinator.addPersistentStoreWithType(storeKind, configuration: nil, URL: storeLocation, options: nil)
        return persistentStoreCoordinator
    }
}

protocol ManagedObject: class {
    /// The type of the value type cover struct vended for instances of this class
    associatedtype Value
    
    static var entityName: String { get }
    
    /// Returns a fresh fetch request instance of this entity.
    static func fetchRequest() -> NSFetchRequest
    
    var identifier: Identifier<Value> { get }
}

extension ManagedObject where Self: NSManagedObject {
    static var entityName: String {
        return String(self)
    }
    
    static func fetchRequest() -> NSFetchRequest {
        let result = NSFetchRequest(entityName: entityName)
        return result
    }
}


