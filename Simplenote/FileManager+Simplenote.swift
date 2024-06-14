import Foundation

extension FileManager {
    var sharedContainerURL: URL {
        containerURL(forSecurityApplicationGroupIdentifier: Bundle.main.sharedGroupDomain)!
    }

    func recoveryDirectoryURL() -> URL? {
        let dir = sharedContainerURL.appendingPathComponent(Constants.recoveryDir)

        do {
            try createDirectoryIfNeeded(at: dir)
        } catch {
            NSLog("Could not create recovery directory because: $@", error.localizedDescription)
            return nil
        }

        return dir
    }

    func createDirectoryIfNeeded(at url: URL, withIntermediateDirectories: Bool = true) throws {
        if directoryExistsAtURL(url) {
            return
        }

        try createDirectory(at: url, withIntermediateDirectories: true)
    }
}

extension FileManager: FileManagerProtocol {
    // This is just a shim for protocol conformance
    func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool) throws {
        try createDirectory(at: url, withIntermediateDirectories: createIntermediates, attributes: nil)
    }
}

private struct Constants {
    static let recoveryDir = "Recovery"
}
