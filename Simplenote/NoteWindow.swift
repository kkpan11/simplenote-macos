//
//  NoteWindow.swift
//  Simplenote
//
//  Created by Charlie Scheer on 4/12/24.
//  Copyright © 2024 Simperium. All rights reserved.
//

import Foundation

class NoteWindow: NSWindow {
    let editor: NoteEditorViewController

    var selectedNoteID: String? {
        editor.note?.simperiumKey
    }

    init() {
        let storyboard = NSStoryboard(name: .main, bundle: nil)
        self.editor = storyboard.instantiateViewController(ofType: NoteEditorViewController.self)

        let rect = NSRect(x: 100, y: 100, width: 100, height: 100)
        super.init(contentRect: rect, styleMask: [.titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: false)

        setupWindow()
    }

    private func setupWindow() {
        contentViewController = editor
        editor.metadataCache = SimplenoteAppDelegate.shared().noteEditorMetadataCache
    }

    // MARK: Show Note
    //
    func show(_ note: Note) {
        editor.toolbarView.sidebarButton.isHidden = true
        editor.displayNote(note)
        title = note.titlePreview
    }
}
