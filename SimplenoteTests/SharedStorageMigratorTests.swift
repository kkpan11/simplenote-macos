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

        migrator.performMigrationIfNeeded()

        XCTAssertTrue(fileManager.migrationAttempted)
    }

    func testMigrationDoesNotRunIfNotNeeded() {
        fileManager.legacyStorageExists = false

        migrator.performMigrationIfNeeded()

        XCTAssertFalse(fileManager.migrationAttempted)
    }

    func testCopyAttemptedIfShouldSucceed() {
        fileManager.legacyStorageExists = true
        fileManager.copyShouldSucceed = true

        migrator.performMigrationIfNeeded()

        XCTAssertTrue(fileManager.migrationAttempted)
        XCTAssertTrue(fileManager.copyAttempted)
    }

    func testCopyNotAttemptedIfShouldFail() {
        fileManager.legacyStorageExists = true
        fileManager.copyShouldSucceed = false

        migrator.performMigrationIfNeeded()

        XCTAssertTrue(fileManager.migrationAttempted)
        XCTAssertFalse(fileManager.copyAttempted)
    }

    func testNoBackupAndFilesRemovedIfValidationFails() {
        storageValidator.validationShouldSucceed = false
        fileManager.legacyStorageExists = true
        fileManager.copyShouldSucceed = true

        migrator.performMigrationIfNeeded()

        XCTAssertTrue(fileManager.migrationAttempted)
        XCTAssertTrue(fileManager.copyAttempted)
        XCTAssertFalse(fileManager.backupAttempted)
        XCTAssertTrue(fileManager.removeFilesAttempted)
    }

    func testConfirmLegacyDBBackUpAttemptedOnSuccess() {
        storageValidator.validationShouldSucceed = true
        fileManager.legacyStorageExists = true
        fileManager.copyShouldSucceed = true

        migrator.performMigrationIfNeeded()

        XCTAssertTrue(fileManager.backupAttempted)
        XCTAssertTrue(fileManager.migrationAttempted)
    }

    func testConfirmSharedFilesRemoveAttemptedOnFailer() {
        storageValidator.validationShouldSucceed = false
        fileManager.legacyStorageExists = true
        fileManager.copyShouldSucceed = true

        migrator.performMigrationIfNeeded()

        XCTAssertTrue(fileManager.removeFilesAttempted)
        XCTAssertTrue(fileManager.migrationAttempted)
    }
}
