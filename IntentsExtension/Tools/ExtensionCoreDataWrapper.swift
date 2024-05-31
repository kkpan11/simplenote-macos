//
//  ExtensionCoreDataWrapper.swift
//  IntentsExtension
//
//  Created by Charlie Scheer on 5/29/24.
//  Copyright © 2024 Simperium. All rights reserved.
//

import Foundation
import CoreData

class ExtensionCoreDataWrapper {
    private lazy var coreDataManager: CoreDataManager? = {
        do {
            return try CoreDataManager(storageSettings: StorageSettings(), for: .intents)
        } catch {
            return nil
        }
    }()

    lazy var resultsController: ExtensionResultsController? = {
        guard let coreDataManager else {
            return nil
        }
        return ExtensionResultsController(context: coreDataManager.managedObjectContext)
    }()

    func context() -> NSManagedObjectContext? {
        guard let coreDataManager else {
            return nil
        }
        return coreDataManager.managedObjectContext
    }
}
