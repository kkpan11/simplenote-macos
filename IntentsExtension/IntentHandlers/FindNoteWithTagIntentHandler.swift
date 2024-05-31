import Intents

class FindNoteWithTagIntentHandler: NSObject, FindNoteWithTagIntentHandling {
    let coreDataWrapper = ExtensionCoreDataWrapper()

    func resolveNote(for intent: FindNoteWithTagIntent, with completion: @escaping (IntentNoteResolutionResult) -> Void) {
        if let selectedNote = intent.note {
            completion(IntentNoteResolutionResult.success(with: selectedNote))
            return
        }

        guard let selectedTag = intent.tag else {
            completion(IntentNoteResolutionResult.needsValue())
            return
        }

        completion(IntentNoteResolutionResult.resolveIntentNote(forTag: selectedTag, in: coreDataWrapper))
    }

    func provideTagOptionsCollection(for intent: FindNoteWithTagIntent, with completion: @escaping (INObjectCollection<IntentTag>?, (any Error)?) -> Void) {
        do {
            let tags = try IntentTag.allTags(in: coreDataWrapper)
            completion(INObjectCollection(items: tags), nil)
        } catch {
            completion(nil, error)
        }
    }

    func handle(intent: FindNoteWithTagIntent, completion: @escaping (FindNoteWithTagIntentResponse) -> Void) {
        
    }
}

/*
 func resolveNote(for intent: FindNoteWithTagIntent) async -> IntentNoteResolutionResult {
     if let selectedNote = intent.note {
         return IntentNoteResolutionResult.success(with: selectedNote)
     }

     guard let selectedTag = intent.tag else {
         return IntentNoteResolutionResult.needsValue()
     }

     return IntentNoteResolutionResult.resolveIntentNote(forTag: selectedTag, in: coreDataWrapper)
 }

 func provideTagOptionsCollection(for intent: FindNoteWithTagIntent) async throws -> INObjectCollection<IntentTag> {
     let tags = try IntentTag.allTags(in: coreDataWrapper)
     return INObjectCollection(items: tags)
 }

 func handle(intent: FindNoteWithTagIntent) async -> FindNoteWithTagIntentResponse {
     guard let note = intent.note else {
         return FindNoteWithTagIntentResponse(code: .failure, userActivity: nil)
     }

     let response = FindNoteWithTagIntentResponse(code: .success, userActivity: nil)
     response.note = note
     return response
 }
 */
