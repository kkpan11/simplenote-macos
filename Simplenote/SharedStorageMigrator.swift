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
        NSLog("Beginning database migration from: \(storageSettings.legacyStorageURL.path ?? "") to: \(storageSettings.sharedStorageURL.path ?? "")")

        //        do {
        //            try migrateCoreDataFiles()
        //            try attemptCreationOfCoreDataStack()
        //            NSLog("Database migration successful!!")
        //            backupLegacyDatabase()
        //            return .success
        //        } catch {
        //            NSLog("Could not migrate database to app group " + error.localizedDescription)
        ////            CrashLogging.logError(error)
        //
        //            removeFailedMigrationFilesIfNeeded()
        //            return .failed
        //        }
        
        return .failed
    }

    private func migrateCoreDataFiles() throws {
        try fileManager.copyItem(at: legacyStorageURL, to: sharedStorageURL)
    }
}


enum MigrationResult {
    case success
    case notNeeded
    case failed
}
