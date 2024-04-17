//
//  NSManagedObjectContext+Simplenote.swift
//  Simplenote
//
//  Created by Charlie Scheer on 4/11/24.
//  Copyright © 2024 Simperium. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    @objc(fetchObjectsForEntityName: withPredicate: error:)
    func fetchObjects(for entityName: String, withPredicate predicate: NSPredicate) throws -> Array<NSFetchRequestResult> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entityDescription = NSEntityDescription.entity(forEntityName: entityName, in: self)

        fetchRequest.entity = entityDescription

        return try fetch(fetchRequest)
    }
}
