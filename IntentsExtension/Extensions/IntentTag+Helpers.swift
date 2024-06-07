//
//  IntentTag+Helpers.swift
//  IntentsExtension
//
//  Created by Charlie Scheer on 5/31/24.
//  Copyright © 2024 Simperium. All rights reserved.
//

import Intents

extension IntentTag {
    static func allTags(in coreDataWrapper: ExtensionCoreDataWrapper) throws -> [IntentTag] {
        guard let tags = coreDataWrapper.resultsController?.tags() else {
            throw IntentsError.couldNotFetchTags
        }

        return tags.map({ IntentTag(identifier: $0.simperiumKey, display: $0.name ?? String()) })
    }
}
