import Foundation
import CoreData

class CoreDataValidator {
    func validateStorage(withModelURL modelURL: URL, storageURL: URL) throws {
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Could not load Managed Object Model at path: \(storageURL.path)")
        }

        try loadPersistentStorage(with: mom, at: storageURL)
    }

    func loadPersistentStorage(with mom: NSManagedObjectModel, at storageURL: URL) throws {
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
}
