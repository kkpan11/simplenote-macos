//
//  NoteWindowController.swift
//  Simplenote
//
//  Created by Charlie Scheer on 4/12/24.
//  Copyright © 2024 Simperium. All rights reserved.
//

import Foundation

class NoteWindowController: NSWindowController {

    init() {
        super.init(window: NoteWindow())
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show(_ note: Note) {
        (window as? NoteWindow)?.show(note)
        showWindow(window)
    }
}
