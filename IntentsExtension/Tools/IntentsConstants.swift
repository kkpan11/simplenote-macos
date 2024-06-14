//
//  IntentsConstants.swift
//  IntentsExtension
//
//  Created by Charlie Scheer on 5/29/24.
//  Copyright © 2024 Simperium. All rights reserved.
//

import Foundation

struct IntentsConstants {
    static let noteIdentifierKey = "OpenNoteIntentHandlerIdentifierKey"
    static let extensionGroupName = Bundle.main.sharedGroupDomain
    static let simperiumBaseURL = "https://api.simperium.com/1"

    static let recoveryMessage = NSLocalizedString("Will attempt to recover shortcut content on next launch", comment: "Alerting users that we will attempt to restore lost content on next launch")
}
