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
        guard let notes = coredataWrapper.resultsController()?.notes() else {
            completion(nil, NSError(domain: "oops", code: 1))
            return
        }
        let intentNotes = notes.compactMap({ IntentNote(identifier: $0.simperiumKey, display: $0.title) })
        let collection = INObjectCollection(items: intentNotes)

        completion(collection, nil)
    }

    func handle(intent: OpenNoteIntent, completion: @escaping (OpenNoteIntentResponse) -> Void) {
        completion(OpenNoteIntentResponse.init(code: .continueInApp, userActivity: nil))
    }
}
