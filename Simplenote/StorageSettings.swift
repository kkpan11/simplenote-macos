import Foundation

class StorageSettings {
    private let fileManager: FileManager

    init(fileManger: FileManager = .default) {
        self.fileManager = fileManger
    }

    var modelURL: URL? {
        Bundle.main.url(forResource: Constants.modelName, withExtension: Constants.modelExtension)
    }

    private var sharedStorageExists: Bool {
        fileManager.fileExists(atPath: sharedStorageURL.path)
    }

    var storageDirectory: URL {
        guard sharedStorageExists else {
            return legacyUserLibraryDirectory
        }

        return sharedUserLibraryDirectory
    }

    var storageURL: URL {
        guard sharedStorageExists else {
            return legacyStorageURL
        }

        return sharedStorageURL
    }

    var legacyBackupURL: URL {
        legacyStorageURL.appendingPathExtension(Constants.oldExtension)
    }

    var legacyUserLibraryDirectory: URL {
        let libraryURL = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).last!
        return libraryURL.appendingPathComponent(Constants.modelName)
    }

    var sharedUserLibraryDirectory: URL {
        fileManager.sharedContainerURL.appendingPathComponent(Constants.dataDirectory)
    }

    var sharedStorageURL: URL {
        sharedUserLibraryDirectory.appendingPathComponent("\(Constants.modelName).\(Constants.storeExtension)")
    }

    var legacyStorageURL: URL {
        legacyUserLibraryDirectory.appendingPathComponent("\(Constants.modelName).\(Constants.storeExtension)")
    }
}

private struct Constants {
    static let modelName = "Simplenote"
    static let modelExtension = "momd"
    static let storeExtension = "storedata"
    static let oldExtension = "old"
    static let dataDirectory = "Data"
}
