//
//  OpenNewNoteIntentHandler.swift
//  Simplenote
//
//  Created by Charlie Scheer on 5/23/24.
//  Copyright © 2024 Simperium. All rights reserved.
//

import Intents

class OpenNewNoteIntentHandler: NSObject, OpenNewNoteIntentHandling {
    func handle(intent: OpenNewNoteIntent, completion: @escaping (OpenNewNoteIntentResponse) -> Void) {
        completion(OpenNewNoteIntentResponse(code: .continueInApp, userActivity: nil))
    }
}
