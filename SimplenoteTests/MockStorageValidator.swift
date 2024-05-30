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
    override func validateStorage(withModelURL modelURL: URL, storageURL: URL) throws {
       // NO-OP
    }
}
