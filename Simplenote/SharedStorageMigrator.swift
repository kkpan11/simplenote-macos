//
//  SharedStorageMigrator.swift
//  Simplenote
//
//  Created by Charlie Scheer on 5/28/24.
//  Copyright © 2024 Simperium. All rights reserved.
//

import Foundation

@objc
class SharedStorageMigrator: NSObject {
    private let storageSettings: StorageSettings
    private let fileManager: FileManager

    private var legacyStorageURL: URL {
        storageSettings.legacyStorageURL
    }

    private var sharedStorageURL: URL {
        storageSettings.sharedStorageURL
    }

    init(storageSettings: StorageSettings = StorageSettings(), fileManager: FileManager = FileManager.default) {
        self.storageSettings = storageSettings
        self.fileManager = fileManager
    }

    private var legacyStorageExists: Bool {
        fileManager.fileExists(atPath: legacyStorageURL.path)
    }

    private var sharedStorageExists: Bool {
        fileManager.fileExists(atPath: sharedStorageURL.path)
    }

    /// Database Migration
    /// To be able to share data with app extensions, the CoreData database needs to be migrated to an app group
    /// Must run before Simperium is setup

    func performMigrationIfNeeded() -> MigrationResult {
        // Confirm if the app group DB exists
        guard migrationNeeded else {
            NSLog("Core Data Migration not required")
            return .notNeeded
        }

        return migrateCoreDataToAppGroup()
    }

    private var migrationNeeded: Bool {
        return legacyStorageExists && !sharedStorageExists
    }

    private func migrateCoreDataToAppGroup() -> MigrationResult {
        NSLog("Database needs migration to app group")
        NSLog("Beginning database migration from: \(storageSettings.legacyStorageURL.path) to: \(storageSettings.sharedStorageURL.path)")

                do {
                    try migrateCoreDataFiles()
                    try attemptCreationOfCoreDataStack()
                    NSLog("Database migration successful!!")
                    backupLegacyDatabase()
                    return .success
                } catch {
                    NSLog("Could not migrate database to app group " + error.localizedDescription)
                    removeFailedMigrationFilesIfNeeded()
                    return .failed
                }
    }

    private func migrateCoreDataFiles() throws {
        if !fileManager.directoryExistsAtURL(storageSettings.sharedUserLibraryDirectory) {
            try fileManager.createDirectory(at: storageSettings.sharedUserLibraryDirectory, withIntermediateDirectories: true)
        }
        try fileManager.copyItem(at: legacyStorageURL, to: sharedStorageURL)
    }

    private func attemptCreationOfCoreDataStack() throws {
        NSLog("Confirming migrated database can be loaded at: \(storageSettings.sharedStorageURL)")
        try loadPersistentStorage(at: storageSettings.sharedStorageURL)
    }

    private func loadPersistentStorage(at storageURL: URL) throws {
        guard let mom = NSManagedObjectModel(contentsOf: storageSettings.modelURL!) else {
            fatalError("Could not load Managed Object Model at path: \(storageURL.path)")
        }
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        let options = [
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true
        ]
        try psc.addPersistentStore(ofType: NSXMLStoreType, configurationName: nil, at: storageURL, options: options)

        // Remove the persistent store before exiting
        // If removing fails, the migration can still continue so not throwing the errors
        do {
            for store in psc.persistentStores {
                try psc.remove(store)
            }
        } catch {
            NSLog("Could not remove temporary persistent Store " + error.localizedDescription)
        }
    }

    private func backupLegacyDatabase() {
        do {
            try fileManager.moveItem(at: storageSettings.legacyStorageURL, to: storageSettings.legacyBackupURL)
        } catch {
            NSLog("Could not backup legacy storage database" + error.localizedDescription)
        }
    }

    private func removeFailedMigrationFilesIfNeeded() {
        guard sharedStorageExists else {
            return
        }

        do {
            try fileManager.removeItem(at: storageSettings.sharedStorageURL)
        } catch {
            NSLog("Could not delete files from failed migration " + error.localizedDescription)
        }
    }
}


enum MigrationResult {
    case success
    case notNeeded
    case failed
}
