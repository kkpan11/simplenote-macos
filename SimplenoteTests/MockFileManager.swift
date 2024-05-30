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
    func fileExists(atPath path: String) -> Bool {
        return true
    }

    func directoryExistsAtURL(_ url: URL) -> Bool {
        return true
    }

    func copyItem(at srcURL: URL, to dstURL: URL) throws {

    }

    func moveItem(at srcURL: URL, to dstURL: URL) throws {

    }

    func removeItem(at URL: URL) throws {

    }

    func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool) throws {
    }

}
