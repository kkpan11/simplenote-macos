import Foundation
import UniformTypeIdentifiers
import CoreData

public class RecoveryUnarchiver {
    private let fileManager: FileManager
    private let simperium: Simperium

    public init(fileManager: FileManager = .default, simperium: Simperium) {
        self.fileManager = fileManager
        self.simperium = simperium
    }

    // MARK: Restore
    //
    public func insertNotesFromRecoveryFilesIfNeeded() {

        guard let recoveryDirURL = fileManager.recoveryDirectoryURL(),
              let recoveryFiles = try? fileManager.contentsOfDirectory(at: recoveryDirURL, includingPropertiesForKeys: nil),
        !recoveryFiles.isEmpty else {
            return
        }

        recoveryFiles.forEach { url in
            insertNote(from: url)
            try? fileManager.removeItem(at: url)
        }
    }

    private func insertNote(from url: URL) {
        guard let note = simperium.notesBucket.insertNewObject() as? Note,
              let data = fileManager.contents(atPath: url.path),
              let recoveredContent = String(data: data, encoding: .utf8) else {
            return
        }

        var content = Constants.recoveredContentHeader
        content += "\n\n"
        content += recoveredContent
        note.content = content

        note.modificationDate = Date()
        note.creationDate = Date()
        note.markdown = UserDefaults.standard.bool(forKey: SPMarkdownPreferencesKey)
        simperium.save()
    }

    private func identifier(from url: URL) -> String? {
        let fileName = url.deletingPathExtension().lastPathComponent
        let components = fileName.components(separatedBy: "-")
        return components.last
    }
 }

private struct Constants {
    static let recoveredContent = "recoveredContent"
    static let richTextKey = "richText"
    static let recoveredContentHeader = NSLocalizedString("Recovered Note Cotent - ", comment: "Header to put on any files that need to be recovered")
}
