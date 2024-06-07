//
//  NSURLSessionConfiguration+Extensions.swift
//  IntentsExtension
//
//  Created by Charlie Scheer on 6/3/24.
//  Copyright © 2024 Simperium. All rights reserved.
//

import Foundation

extension URLSessionConfiguration {
    /// Returns a new Background Session Configuration, with a random identifier.
    ///
    class func backgroundSessionConfigurationWithRandomizedIdentifier() -> URLSessionConfiguration {
        let identifier = IntentsConstants.extensionGroupName + "." + UUID().uuidString
        let configuration = URLSessionConfiguration.background(withIdentifier: identifier)
        configuration.sharedContainerIdentifier = IntentsConstants.extensionGroupName

        return configuration
    }
}
