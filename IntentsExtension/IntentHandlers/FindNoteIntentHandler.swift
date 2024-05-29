//
//  FindNoteIntentHandler.swift
//  IntentsExtension
//
//  Created by Charlie Scheer on 5/29/24.
//  Copyright © 2024 Simperium. All rights reserved.
//

import Intents

class FindNoteIntentHandler: NSObject, FindNoteIntentHandling {
    let coreDataWrapper = ExtensionCoreDataWrapper()

    func resolveNote(for intent: FindNoteIntent, with completion: @escaping (IntentNoteResolutionResult) -> Void) {
        // If the user has already selected a note return that note with success
        if let selectedNote = intent.note {
            completion(IntentNoteResolutionResult.success(with: selectedNote))
            return
        }

        guard let content = intent.content else {
            completion(IntentNoteResolutionResult.needsValue())
            return
        }

        completion(IntentNoteResolutionResult.resolveIntentNote(for: content, in: coreDataWrapper))
    }

    func provideNoteOptionsCollection(for intent: FindNoteIntent, with completion: @escaping (INObjectCollection<IntentNote>?, (any Error)?) -> Void) {
        do {
            let intentNotes = try IntentNote.allNotes(in: coreDataWrapper)
            completion(INObjectCollection(items: intentNotes), nil)
        } catch {
            completion(nil, IntentsError.couldNotFetchNotes)
        }
    }

    func handle(intent: FindNoteIntent, completion: @escaping (FindNoteIntentResponse) -> Void) {
        guard let intentNote = intent.note else {
            completion(FindNoteIntentResponse(code: .failure, userActivity: nil))
            return
        }

        let success = FindNoteIntentResponse(code: .success, userActivity: nil)
        success.note = intentNote

        completion(success)
    }
}
