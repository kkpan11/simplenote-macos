//
//  OpenNoteIntentHandler.swift
//  IntentsExtension
//
//  Created by Charlie Scheer on 5/29/24.
//  Copyright © 2024 Simperium. All rights reserved.
//

import Intents

class OpenNoteIntentHandler: NSObject, OpenNoteIntentHandling {
    let coredataWrapper = ExtensionCoreDataWrapper()

    func provideNoteOptionsCollection(for intent: OpenNoteIntent, with completion: @escaping (INObjectCollection<IntentNote>?, (any Error)?) -> Void) {
        do {
            let intentNotes = try IntentNote.allNotes(in: coredataWrapper)
            completion(INObjectCollection(items: intentNotes), nil)
        } catch {
            completion(nil, IntentsError.couldNotFetchNotes)
        }
    }

    func handle(intent: OpenNoteIntent, completion: @escaping (OpenNoteIntentResponse) -> Void) {
        completion(OpenNoteIntentResponse.init(code: .continueInApp, userActivity: nil))
    }
}
