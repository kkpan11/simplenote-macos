//
//  StorageSettings.swift
//  Simplenote
//
//  Created by Charlie Scheer on 5/23/24.
//  Copyright © 2024 Simperium. All rights reserved.
//

import Foundation

class StorageSettings {
    let fileManager: FileManager

    init(fileManger: FileManager = .default) {
        self.fileManager = fileManger
    }

    var legacyUserLibraryDirectory: URL {
        let libraryURL = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).last!
        return libraryURL.appendingPathComponent(Constants.modelName)
    }

    var modelURL: URL? {
        Bundle.main.url(forResource: Constants.modelName, withExtension: Constants.modelExtension)
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

    var legacyBackupURL: URL {
        legacyStorageURL.appendingPathExtension(Constants.oldExtension)
    }
}

private struct Constants {
    static let modelName = "Simplenote"
    static let modelExtension = "momd"
    static let storeExtension = "storedata"
    static let oldExtension = "old"
    static let dataDirectory = "Data"
}
