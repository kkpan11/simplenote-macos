//
//  CopyNoteContentIntentHandler.swift
//  IntentsExtension
//
//  Created by Charlie Scheer on 5/29/24.
//  Copyright © 2024 Simperium. All rights reserved.
//

import Intents

class CopyNoteContentIntentHandler: NSObject, CopyNoteContentIntentHandling {
    let coreDataWrapper = ExtensionCoreDataWrapper()

    func provideNoteOptionsCollection(for intent: CopyNoteContentIntent, with completion: @escaping (INObjectCollection<IntentNote>?, (any Error)?) -> Void) {
        do {
            let intentNotes = try IntentNote.allNotes(in: coreDataWrapper)
            completion(INObjectCollection(items: intentNotes), nil)
        } catch {
            completion(nil, IntentsError.couldNotFetchNotes)
        }
    }

    func handle(intent: CopyNoteContentIntent, completion: @escaping (CopyNoteContentIntentResponse) -> Void) {
        guard let note = intent.note else {
            completion(CopyNoteContentIntentResponse(code: .unspecified, userActivity: nil))
            return
        }

        guard let identifier = note.identifier,
              let content = coreDataWrapper.resultsController?.note(forSimperiumKey: identifier)?.content else {
            completion(CopyNoteContentIntentResponse(code: .failure, userActivity: nil))
            return
        }

        let response = CopyNoteContentIntentResponse(code: .success, userActivity: nil)
        response.noteContent = content
        completion(response)
    }
}
