//
//  MockStorageValidator.swift
//  SimplenoteTests
//
//  Created by Charlie Scheer on 5/30/24.
//  Copyright © 2024 Simperium. All rights reserved.
//

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
