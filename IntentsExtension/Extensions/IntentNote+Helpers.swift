//
//  IntentNote.swift
//  IntentsExtension
//
//  Created by Charlie Scheer on 5/29/24.
//  Copyright © 2024 Simperium. All rights reserved.
//

import Intents

extension IntentNote {
    static func allNotes(in coreDataWrapper: ExtensionCoreDataWrapper) throws -> [IntentNote] {
        guard let notes = coreDataWrapper.resultsController()?.notes() else {
            throw IntentsError.couldNotFetchNotes
        }

        return makeIntentNotes(from: notes)
    }

    static func makeIntentNotes(from notes: [Note]) -> [IntentNote] {
        notes.map({ IntentNote(identifier: $0.simperiumKey, display: $0.title) })
    }
}
