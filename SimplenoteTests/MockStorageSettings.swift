//
//  MockStorageSettings.swift
//  SimplenoteTests
//
//  Created by Charlie Scheer on 5/30/24.
//  Copyright © 2024 Simperium. All rights reserved.
//

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
