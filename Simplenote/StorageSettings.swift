//
//  StorageSettings.swift
//  Simplenote
//
//  Created by Charlie Scheer on 5/23/24.
//  Copyright © 2024 Simperium. All rights reserved.
//

import Foundation

enum StorageLocation {
    case shared
    case legacy
}

class StorageSettings {
    private let fileManager: FileManager
    private var storageLocation: StorageLocation

    init(fileManger: FileManager = .default, storageLocation: StorageLocation = .shared) {
        self.fileManager = fileManger
        self.storageLocation = storageLocation
    }

    var modelURL: URL? {
        Bundle.main.url(forResource: Constants.modelName, withExtension: Constants.modelExtension)
    }

    var storageDirectory: URL {
        switch storageLocation {
        case .shared:
            return sharedUserLibraryDirectory
        case .legacy:
            return legacyUserLibraryDirectory
        }
    }

    var storageURL: URL {
        switch storageLocation {
        case .shared:
            return sharedStorageURL
        case .legacy:
            return legacyStorageURL
        }
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

    func setStorageLocation(to newLocation: StorageLocation) {
        storageLocation = newLocation
    }
}

private struct Constants {
    static let modelName = "Simplenote"
    static let modelExtension = "momd"
    static let storeExtension = "storedata"
    static let oldExtension = "old"
    static let dataDirectory = "Data"
}
