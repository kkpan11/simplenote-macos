//
//  FileManager+Intents.swift
//  IntentsExtension
//
//  Created by Charlie Scheer on 5/31/24.
//  Copyright © 2024 Simperium. All rights reserved.
//

import Foundation

// This exists in a8cTracks but we aren't currently importing that into intents but we need this for FileManager to meet FileManagerProtocol
extension FileManager {
    func directoryExistsAtURL(_ url: URL) -> Bool {
        var isDir: ObjCBool = false
        let exists = self.fileExists(atPath: url.path, isDirectory: &isDir)
        return exists && isDir.boolValue
    }
}
