import Foundation
@testable import Simplenote

class MockStorageValidator: CoreDataValidator {
    var validationShouldSucceed = true

    override func validateStorage(withModelURL modelURL: URL, storageURL: URL) throws {
        if !validationShouldSucceed {
            throw NSError(domain: "TestError", code: 1)
        }
    }
}
