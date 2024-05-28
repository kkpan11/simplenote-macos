//
//  FileManager+Simplenote.swift
//  Simplenote
//
//  Created by Charlie Scheer on 5/28/24.
//  Copyright © 2024 Simperium. All rights reserved.
//

import Foundation

extension FileManager {
    var sharedContainerURL: URL {
        containerURL(forSecurityApplicationGroupIdentifier: Bundle.main.rootBundleIdentifier)!
    }
}
