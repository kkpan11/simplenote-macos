//
//  OpenNoteIntentHandler.swift
//  IntentsExtension
//
//  Created by Charlie Scheer on 5/29/24.
//  Copyright © 2024 Simperium. All rights reserved.
//

import Intents

class OpenNoteIntentHandler: NSObject, OpenNoteIntentHandling {
    func provideNoteOptionsCollection(for intent: OpenNoteIntent, with completion: @escaping (INObjectCollection<IntentNote>?, (any Error)?) -> Void) {
        completion(nil, nil)
    }

    func handle(intent: OpenNoteIntent, completion: @escaping (OpenNoteIntentResponse) -> Void) {
        completion(OpenNoteIntentResponse.init(code: .continueInApp, userActivity: nil))
    }
}
