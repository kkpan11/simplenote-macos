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
        guard let identifier = intent.note?.identifier else {
            completion(OpenNoteIntentResponse(code: .failure, userActivity: nil))
            return
        }

        let activity = NSUserActivity(activityType: ActivityType.openNoteShortcut.rawValue)
        activity.userInfo = [IntentsConstants.noteIdentifierKey: identifier]

        completion(OpenNoteIntentResponse(code: .continueInApp, userActivity: activity))
    }
}
