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
    private let fileManager: FileManagerProtocol
    private let storageValidator: CoreDataValidator

    private var legacyStorageURL: URL {
        storageSettings.legacyStorageURL
    }

    private var sharedStorageURL: URL {
        storageSettings.sharedStorageURL
    }

    init(storageSettings: StorageSettings = StorageSettings(), fileManager: FileManagerProtocol = FileManager.default,
         storageValidator: CoreDataValidator = CoreDataValidator()) {
        self.storageSettings = storageSettings
        self.fileManager = fileManager
        self.storageValidator = storageValidator
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

    func performMigrationIfNeeded() -> StorageSettings {
        if migrationNeeded {
            migrateCoreDataToAppGroup()
        }

        return storageSettings
    }

    private var migrationNeeded: Bool {
        return legacyStorageExists
    }

    private func migrateCoreDataToAppGroup() {
        NSLog("Database needs migration to app group")
        NSLog("Beginning database migration from: \(storageSettings.legacyStorageURL.path) to: \(storageSettings.sharedStorageURL.path)")

        do {
            try migrateCoreDataFiles()
            try attemptCreationOfCoreDataStack()
            NSLog("Database migration successful!!")
            backupLegacyDatabase()
        } catch {
            NSLog("Could not migrate database to app group " + error.localizedDescription)
            storageSettings.setStorageLocation(to: .legacy)
            removeFailedMigrationFilesIfNeeded()
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
        try storageValidator.validateStorage(withModelURL: storageSettings.modelURL!, storageURL: storageSettings.sharedStorageURL)
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
