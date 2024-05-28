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
    case noStorageURL

    var description: String {
        switch self {
        case .couldNotBuildModel:
            return "Could not build model from URL"
        case .noApplicationFilesDirectoryURL:
            return "No url found for the application files directory"
        case .foundNotDirectoryAtFilesDirectoryURL:
            return "Item at applications files url is not a directory"
        case .noStorageURL:
            return "Could not make storage url"
        }
    }
}

@objcMembers
class CoreDataManager: NSObject {
    private(set) var managedObjectModel: NSManagedObjectModel
    private(set) var managedObjectContext: NSManagedObjectContext
    private(set) var persistentStoreCoordinator: NSPersistentStoreCoordinator

    init(at storageURL: URL, storageSettings: StorageSettings = StorageSettings()) throws {
        guard let modelURL = storageSettings.modelURL,
              let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            throw CoreDataManagerError.couldNotBuildModel
        }

        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

        let psc = try Self.preparePSC(at: storageURL, model: mom)

        self.managedObjectModel = mom
        self.managedObjectContext = context
        self.persistentStoreCoordinator = psc
    }

    static private func preparePSC(at storageURL: URL, model: NSManagedObjectModel) throws -> NSPersistentStoreCoordinator {
        let options = [
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true
        ]
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)

        try coordinator.addPersistentStore(ofType: NSXMLStoreType, configurationName: nil, at: storageURL, options: options)

        return coordinator
    }
}
