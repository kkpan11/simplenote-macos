import Foundation

extension FileManager {
    var sharedContainerURL: URL {
        containerURL(forSecurityApplicationGroupIdentifier: Bundle.main.sharedGroupDomain)!
    }

    var recoveryDirectoryURL: URL {
        sharedContainerURL.appendingPathComponent(Constants.recoveryDir)
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
