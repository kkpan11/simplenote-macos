//
//  NoteWindowController.swift
//  Simplenote
//
//  Created by Charlie Scheer on 4/12/24.
//  Copyright © 2024 Simperium. All rights reserved.
//

import Foundation

class NoteWindowController: NSWindowController {
    let editor: NoteEditorViewController

    init() {
        let storyboard = NSStoryboard(name: .main, bundle: nil)
        let noteEditor = storyboard.instantiateViewController(ofType: NoteEditorViewController.self)

        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let fileURL = URL(fileURLWithPath: documentsDirectory, isDirectory: true).appendingPathComponent(".editor-metadata-cache")
        let noteEditorMetadataCache = NoteEditorMetadataCache(storage: FileStorage(fileURL: fileURL))

        noteEditor.metadataCache = noteEditorMetadataCache

        let window = NoteWindow(contentViewController: noteEditor)

        self.editor = noteEditor

        super.init(window: window)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show(_ note: Note) {
        editor.toolbarView.sidebarButton.isHidden = true
        editor.displayNote(note)

        showWindow(window)
    }
}
