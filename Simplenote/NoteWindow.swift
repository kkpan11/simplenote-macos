//
//  NoteWindow.swift
//  Simplenote
//
//  Created by Charlie Scheer on 4/12/24.
//  Copyright © 2024 Simperium. All rights reserved.
//

import Foundation

class NoteWindow: NSWindow {
    // The note windows are stored in the windows manager and need to be removed when they close
    // This override cleans up the windows in the manager
    override func close() {
        super.close()
        let noteWindowsManager = SimplenoteAppDelegate.shared().noteWindowsManager
        if let controller = windowController,
           let index = noteWindowsManager.windowControllers.firstIndex(of: controller) {
            noteWindowsManager.windowControllers.remove(at: index)
        }
    }
}
