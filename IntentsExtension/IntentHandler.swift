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
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
}
