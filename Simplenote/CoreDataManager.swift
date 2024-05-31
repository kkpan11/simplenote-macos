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

enum CoreDataUsageType {
    case standard
    case intents
}

@objcMembers
class CoreDataManager: NSObject {
    private(set) var managedObjectModel: NSManagedObjectModel
    private(set) var managedObjectContext: NSManagedObjectContext
    private(set) var persistentStoreCoordinator: NSPersistentStoreCoordinator

    init(storageSettings: StorageSettings, for usageType: CoreDataUsageType = .standard) throws {
        guard let modelURL = storageSettings.modelURL,
              let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            throw CoreDataManagerError.couldNotBuildModel
        }

        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

        let psc = try Self.preparePSC(at: storageSettings.storageURL, model: mom)

        self.managedObjectModel = mom
        self.managedObjectContext = context
        self.persistentStoreCoordinator = psc

        super.init()
        setupCoreDataStackIfNeeded(usage: usageType)
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

    private func setupCoreDataStackIfNeeded(usage: CoreDataUsageType) {
        guard usage != .standard else {
            return
        }

        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
    }
}
