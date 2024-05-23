//
//  ShortcutHandler.swift
//  Simplenote
//
//  Created by Charlie Scheer on 5/23/24.
//  Copyright © 2024 Simperium. All rights reserved.
//

import Foundation

class ShortcutsHandler: NSObject {
    @objc
    static var shared = ShortcutsHandler()

    /// Is User authenticated?
    ///
    private var isAuthenticated: Bool {
        return SimplenoteAppDelegate.shared().simperium.user?.authenticated() == true
    }

    /// Handles a UserActivity instance. Returns true on success.
    ///
    @objc
    func handleUserActivity(_ userActivity: NSUserActivity) -> Bool {
        guard let type = ActivityType(rawValue: userActivity.activityType),
              isAuthenticated else {
            return false
        }

        switch type {
        case .newNoteShortcut:
            SimplenoteAppDelegate.shared().noteEditorViewController.createNote(from: nil)
        }

        return true
    }
}
