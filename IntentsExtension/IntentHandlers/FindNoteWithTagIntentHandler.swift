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
        guard let note = intent.note else {
            completion(FindNoteWithTagIntentResponse(code: .failure, userActivity: nil))
            return
        }

        let response = FindNoteWithTagIntentResponse(code: .success, userActivity: nil)
        response.note = note
        completion(response)
    }
}
