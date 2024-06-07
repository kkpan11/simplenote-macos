//
//  IntentHandler.swift
//  IntentsExtension
//
//  Created by Charlie Scheer on 5/23/24.
//  Copyright © 2024 Simperium. All rights reserved.
//

import Intents

class IntentHandler: INExtension {
    override func handler(for intent: INIntent) -> Any {
        switch intent {
        case is OpenNewNoteIntent:
            return OpenNewNoteIntentHandler()
        case is OpenNoteIntent:
            return OpenNoteIntentHandler()
        case is FindNoteIntent:
            return FindNoteIntentHandler()
        case is FindNoteWithTagIntent:
            return FindNoteWithTagIntentHandler()
        case is CopyNoteContentIntent:
            return CopyNoteContentIntentHandler()
        case is AppendNoteIntent:
            return AppendNoteIntentHandler()
        case is CreateNewNoteIntent:
            return CreateNewNoteIntentHandler()
        default:
            return self
        }
    }
}
