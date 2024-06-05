//
//  NSString+Intents.swift
//  IntentsExtension
//
//  Created by Charlie Scheer on 5/31/24.
//  Copyright © 2024 Simperium. All rights reserved.
//

import Foundation

extension NSString {
    /// Encodes the receiver as a `Tag Hash`
    ///
    @objc
    var byEncodingAsTagHash: String {
        precomposedStringWithCanonicalMapping
            .lowercased()
            .addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? self as String
    }
}
