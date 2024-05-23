//
//  CoreDataManager.swift
//  Simplenote
//
//  Created by Charlie Scheer on 5/23/24.
//  Copyright © 2024 Simperium. All rights reserved.
//

import Foundation
import CoreData

@objcMembers
class CoreDataManager: NSObject {
    private(set) var managedObjectModel: NSManagedObjectModel
    private(set) var managedObjectContext: NSManagedObjectContext
    private(set) var persistentStoreCoordinator: NSPersistentStoreCoordinator

    init(managedObjectModel: NSManagedObjectModel, managedObjectContext: NSManagedObjectContext, persistentStoreCoordinator: NSPersistentStoreCoordinator) {
        self.managedObjectModel = managedObjectModel
        self.managedObjectContext = managedObjectContext
        self.persistentStoreCoordinator = persistentStoreCoordinator
    }
}
