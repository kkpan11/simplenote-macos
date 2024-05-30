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
        fileManager = MockFileManager()
        storageSettings = MockStorageSettings()
        storageValidator = MockStorageValidator()

        migrator = SharedStorageMigrator(storageSettings: storageSettings, fileManager: fileManager, storageValidator: storageValidator)
    }

    override func tearDown() {
        fileManager = nil
        storageSettings = nil
        storageValidator = nil
        migrator = nil
    }

    func testMigrationRunsIfNeeded() {
        fileManager.legacyStorageExists = true

        _ = migrator.performMigrationIfNeeded()

        XCTAssertTrue(fileManager.migrationAttempted)
    }

    func testMigrationDoesNotRunIfNotNeeded() {
        fileManager.legacyStorageExists = false

        _ = migrator.performMigrationIfNeeded()

        XCTAssertFalse(fileManager.migrationAttempted)
    }

    func testStorageLocationIsSharedIfCopySuccessful() {
        fileManager.legacyStorageExists = true
        fileManager.copyShouldSucceed = true

        _ = migrator.performMigrationIfNeeded()

        XCTAssertTrue(fileManager.migrationAttempted)
        XCTAssertEqual(storageSettings.storageURL, MockStorageSettings().sharedStorageURL)
    }

    func testStorageLocationIsLegacyIfCopyFails() {
        fileManager.legacyStorageExists = true
        fileManager.copyShouldSucceed = false

        _ = migrator.performMigrationIfNeeded()

        XCTAssertTrue(fileManager.migrationAttempted)
        XCTAssertEqual(storageSettings.storageURL, MockStorageSettings().legacyStorageURL)
    }

    func testStorageLocationIsSharedIfStorageValidationSucceeds() {
        storageValidator.validationShouldSucceed = true
        fileManager.legacyStorageExists = true
        fileManager.copyShouldSucceed = true

        _ = migrator.performMigrationIfNeeded()
        
        XCTAssertTrue(fileManager.migrationAttempted)
        XCTAssertEqual(storageSettings.storageURL, MockStorageSettings().sharedStorageURL)
    }
}
