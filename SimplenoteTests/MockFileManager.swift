import Foundation
@testable import Simplenote

class MockFileManager: FileManagerProtocol {

    var migrationAttempted = false
    var backupAttempted = false
    var removeFilesAttempted = false

    var copyShouldSucceed = true

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

        if copyShouldSucceed {
            sharedStorageExists = true
        } else {
            throw NSError(domain: "testError", code: 1)
        }
    }

    func moveItem(at srcURL: URL, to dstURL: URL) throws {
        backupAttempted = true
    }

    func removeItem(at URL: URL) throws {
        removeFilesAttempted = true
    }

    func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool) throws {
        // NO-OP
    }

}
