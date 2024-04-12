//
//  NoteWindowsManager.swift
//  Simplenote
//
//  Created by Charlie Scheer on 4/12/24.
//  Copyright © 2024 Simperium. All rights reserved.
//

import Foundation

// A wrapper class to hold onto instances of NSWindowController for popout note editors
@objcMembers
class NoteWindowsManager: NSObject {
    var windowControllers: [NSWindowController] = []
}
