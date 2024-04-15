//
//  NoteWindowManager.swift
//  Simplenote
//
//  Created by Charlie Scheer on 4/15/24.
//  Copyright © 2024 Simperium. All rights reserved.
//

import Foundation

class NoteWindowController: NSWindowController {
    init(note: Note) {
        let window = NoteWindow(note: note)
        super.init(window: window)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class NoteWindowManager: NSObject {
    var controllers = Set<NSWindowController>()

    func prepareWindowController(for note: Note) -> NSWindowController {
        let windowController = NoteWindowController(note: note)
        windowController.window?.delegate = self

        controllers.insert(windowController)

        return windowController
    }
}

extension NoteWindowManager: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow,
           let controller = window.windowController {
            controllers.remove(controller)
        }
    }
}
