import Intents

class CreateNewNoteIntentHandler: NSObject, CreateNewNoteIntentHandling {
    let coreDataWrapper = ExtensionCoreDataWrapper()

    func handle(intent: CreateNewNoteIntent) async -> CreateNewNoteIntentResponse {
        guard let content = intent.content,
              let token = KeychainManager.extensionToken,
              let note = note(with: content) else {
            return CreateNewNoteIntentResponse(code: .failure, userActivity: nil)
        }

        Uploader(simperiumToken: token).send(note)
        return CreateNewNoteIntentResponse(code: .success, userActivity: nil)
    }

    private func note(with content: String) -> Note? {
        guard let context = coreDataWrapper.context() else {
            return nil
        }
        let note = Note(context: context)
        note.creationDate = .now
        note.modificationDate = .now
        note.content = content

        return note
    }
}
