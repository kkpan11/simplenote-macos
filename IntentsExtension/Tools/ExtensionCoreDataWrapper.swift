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
    private lazy var coreDataManager: CoreDataManager = {
        do {
            return try CoreDataManager(storageSettings: StorageSettings(), for: .intents)
        } catch {
            fatalError()
        }
    }()

    private lazy var extensionResultsController: ExtensionResultsController = {
        ExtensionResultsController(context: coreDataManager.managedObjectContext)
    }()

    func resultsController() -> ExtensionResultsController? {
        guard FileManager.default.fileExists(atPath: StorageSettings().sharedStorageURL.path) else {
            return nil
        }
        return extensionResultsController
    }

    func context() -> NSManagedObjectContext {
        coreDataManager.managedObjectContext
    }
}
