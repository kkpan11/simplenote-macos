import Foundation

protocol FileManagerProtocol {
    func fileExists(atPath path: String) -> Bool
    func directoryExistsAtURL(_ url: URL) -> Bool
    func copyItem(at srcURL: URL, to dstURL: URL) throws
    func moveItem(at srcURL: URL, to dstURL: URL) throws
    func removeItem(at URL: URL) throws
    func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool) throws
}
