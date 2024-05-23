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

    init(storageSettings: StorageSettings = StorageSettings()) throws {
        guard let modelURL = storageSettings.modelURL,
              let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            throw NSError(domain: "CoreDataManager", code: 1)
        }

        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        let psc = try Self.preparePSC(with: storageSettings, model: mom)

        self.managedObjectModel = mom
        self.managedObjectContext = context
        self.persistentStoreCoordinator = psc
    }

    static private func preparePSC(with storageSettings: StorageSettings, model: NSManagedObjectModel) throws -> NSPersistentStoreCoordinator {
        guard let applicationFilesDirectory = storageSettings.applicationFilesDirectory else {
            throw NSError(domain: "CoreDataManager", code: 1)
        }

        // Validate the directory for the store DB
        do {
            try Self.validateResourceValueForDirectory(at: applicationFilesDirectory)
        } catch {
            try handleDirectoryError((error as NSError), directoryURL: applicationFilesDirectory)
        }


        let options = [
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true
        ]
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)

        try coordinator.addPersistentStore(ofType: NSXMLStoreType, configurationName: nil, at: storageSettings.storageURL, options: options)

        return coordinator
    }

    static private func validateResourceValueForDirectory(at url: URL) throws {
        let properties = try url.resourceValues(forKeys: [URLResourceKey.isDirectoryKey])

        if properties.isDirectory != true {
            let failureDescription = String(format: "Expected a folder to store application data, found a file (%@).", url.path)
            var dict: [String: Any] = [:]
            dict[NSLocalizedDescriptionKey] = failureDescription
            let error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 101, userInfo: dict)
            throw error
        }
    }

    static private func handleDirectoryError(_ error: NSError, directoryURL: URL) throws {
        if error.code == NSFileReadNoSuchFileError {
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
        } else {
            throw error
        }
    }
}
