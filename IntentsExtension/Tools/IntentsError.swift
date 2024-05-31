//
//  IntentsError.swift
//  IntentsExtension
//
//  Created by Charlie Scheer on 5/29/24.
//  Copyright © 2024 Simperium. All rights reserved.
//

import Foundation

enum IntentsError: Error {
    case couldNotFetchNotes

    var title: String {
        switch self {
        case .couldNotFetchNotes:
            return NSLocalizedString("Could not fetch Notes", comment: "Note fetch error title")
        }
    }

    var message: String {
        switch self {
        case .couldNotFetchNotes:
            return NSLocalizedString("Attempt to fetch notes failed.  Please try again later.", comment: "Data Fetch error message")
        }
    }
}
