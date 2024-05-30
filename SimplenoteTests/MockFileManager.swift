//
//  MockFileManager.swift
//  SimplenoteTests
//
//  Created by Charlie Scheer on 5/30/24.
//  Copyright © 2024 Simperium. All rights reserved.
//

import Foundation
@testable import Simplenote

class MockFileManager: FileManagerProtocol {
    var migrationAttempted = false

    var legacyStorageExists = true
    var sharedStorageExists = false

    func fileExists(atPath path: String) -> Bool {
        if path == MockStorageSettings().legacyStorageURL.path {
            return legacyStorageExists
        } else if path == MockStorageSettings().sharedStorageURL.path {
            return sharedStorageExists
        }

        return false
    }

    func directoryExistsAtURL(_ url: URL) -> Bool {
        if url.path == MockStorageSettings().legacyUserLibraryDirectory.path {
            return legacyStorageExists
        } else if url.path == MockStorageSettings().sharedUserLibraryDirectory.path {
            return sharedStorageExists
        }

        return false
    }

    func copyItem(at srcURL: URL, to dstURL: URL) throws {
        migrationAttempted = true
    }

    func moveItem(at srcURL: URL, to dstURL: URL) throws {

    }

    func removeItem(at URL: URL) throws {

    }

    func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool) throws {
        // NO-OP
    }

}
