import Foundation
@testable import Simplenote

class MockStorageSettings: StorageSettings {
    override var legacyStorageURL: URL {
        URL(string: "file:///legacyStorage.com")!
    }

    override var sharedStorageURL: URL {
        URL(string: "//sharedStorage.url")!
    }
}
