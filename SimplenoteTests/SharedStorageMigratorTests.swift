//
//  SharedStorageMigratorTests.swift
//  SimplenoteTests
//
//  Created by Charlie Scheer on 5/30/24.
//  Copyright © 2024 Simperium. All rights reserved.
//

import Foundation
import XCTest
@testable import Simplenote

class SharedStorageMigratorTests: XCTestCase {
    var fileManager: MockFileManager!
    var storageSettings: MockStorageSettings!
    var storageValidator: MockStorageValidator!
    var migrator: SharedStorageMigrator!

    override func setUp() {
        storageSettings = MockStorageSettings()
        fileManager = MockFileManager()
        storageValidator = MockStorageValidator()

        migrator = SharedStorageMigrator(storageSettings: storageSettings, fileManager: fileManager, storageValidator: storageValidator)
    }

    func testMigrationRunsIfNeeded() {

        _ = migrator.performMigrationIfNeeded()

        XCTAssertTrue(fileManager.migrationAttempted)
    }

    func testMigrationDoesNotRunIfNotNeeded() {
        fileManager.legacyStorageExists = false

        _ = migrator.performMigrationIfNeeded()

        XCTAssertFalse(fileManager.migrationAttempted)
    }
}
