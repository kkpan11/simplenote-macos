//
//  ExtensionResultsController.swift
//  IntentsExtension
//
//  Created by Charlie Scheer on 5/29/24.
//  Copyright © 2024 Simperium. All rights reserved.
//

import Foundation
import CoreData
import SimplenoteSearch
import SimplenoteFoundation

class ExtensionResultsController {

    /// Data Controller
    ///
    let managedObjectContext: NSManagedObjectContext

    /// Initialization
    ///
    init(context: NSManagedObjectContext) {
        self.managedObjectContext = context
    }

    // MARK: - Notes

    /// Fetch notes with given tag and limit
    /// If no tag is specified, will fetch notes that are not deleted. If there is no limit specified it will fetch all of the notes
    ///
    func notes(limit: Int = .zero) -> [Note]? {
        let request: NSFetchRequest<Note> = fetchRequestForNotes(limit: limit)
        return performFetch(from: request)
    }

    /// Returns note given a simperium key
    ///
    func note(forSimperiumKey key: String) -> Note? {
        return notes()?.first { note in
            note.simperiumKey == key
        }
    }

    func noteExists(forSimperiumKey key: String) -> Bool {
        note(forSimperiumKey: key) != nil
    }

    private func fetchRequestForNotes(limit: Int = .zero) -> NSFetchRequest<Note> {
        let fetchRequest = NSFetchRequest<Note>(entityName: Note.entityName)
        fetchRequest.fetchLimit = limit
        fetchRequest.sortDescriptors = [NSSortDescriptor.descriptorForNotes(sortMode: .alphabeticallyAscending)]
        fetchRequest.predicate = NSPredicate.predicateForNotes(deleted: false)

        return fetchRequest
    }

    // MARK: Fetching

    private func performFetch<T: NSManagedObject>(from request: NSFetchRequest<T>) -> [T]? {
        do {
            let objects = try managedObjectContext.fetch(request)
            return objects
        } catch {
            NSLog("Couldn't fetch objects: %@", error.localizedDescription)
            return nil
        }
    }
}
