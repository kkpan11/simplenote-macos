//
//  CoreDataManager.swift
//  Simplenote
//
//  Created by Charlie Scheer on 5/23/24.
//  Copyright © 2024 Simperium. All rights reserved.
//

import Foundation
import CoreData

enum CoreDataManagerError: Error {
    case couldNotBuildModel
    case noApplicationFilesDirectoryURL
    case foundNotDirectoryAtFilesDirectoryURL

    var description: String {
        switch self {
        case .couldNotBuildModel:
            return "Could not build model from URL"
        case .noApplicationFilesDirectoryURL:
            return "No url found for the application files directory"
        case .foundNotDirectoryAtFilesDirectoryURL:
            return "Item at applications files url is not a directory"
        }
    }
}

@objcMembers
class CoreDataManager: NSObject {
    private(set) var managedObjectModel: NSManagedObjectModel
    private(set) var managedObjectContext: NSManagedObjectContext
    private(set) var persistentStoreCoordinator: NSPersistentStoreCoordinator

    init(storageSettings: StorageSettings = StorageSettings()) throws {
        guard let modelURL = storageSettings.modelURL,
              let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            throw CoreDataManagerError.couldNotBuildModel
        }

        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        let psc = try Self.preparePSC(with: storageSettings, model: mom)

        self.managedObjectModel = mom
        self.managedObjectContext = context
        self.persistentStoreCoordinator = psc
    }

    static private func preparePSC(with storageSettings: StorageSettings, model: NSManagedObjectModel) throws -> NSPersistentStoreCoordinator {
        guard let applicationFilesDirectory = storageSettings.applicationFilesDirectory else {
            throw CoreDataManagerError.noApplicationFilesDirectoryURL
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
            throw CoreDataManagerError.foundNotDirectoryAtFilesDirectoryURL
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
