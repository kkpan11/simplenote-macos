import Foundation

// MARK: - KeychainManager
//
enum KeychainManager {

    /// Simplenote's Share Extension Token
    ///
    @KeychainItemWrapper(service: SimplenoteKeychain.extensionService, account: SimplenoteKeychain.extensionAccount, accessGroup: Bundle.main.sharedGroupDomain)
    static var extensionToken: String?
}

// MARK: - KeychainItemWrapper
//
@propertyWrapper
struct KeychainItemWrapper {

    let item: KeychainPasswordItem

    /// Designated Initializer
    ///
    init(service: String, account: String, accessGroup: String?) {
        item = KeychainPasswordItem(service: service, account: account, accessGroup: accessGroup)
    }

    var wrappedValue: String? {
        mutating get {
            do {
                return try item.readPassword()

            } catch KeychainError.noPassword {
                return nil

            } catch {
                NSLog("Error Reading Keychain Item \(item.service).\(item.account): \(error)")
                return nil
            }
        }
        set {
            do {
                if let value = newValue {
                    try item.savePassword(value)
                } else {
                    try item.deleteItem()
                }
            } catch {
                NSLog("Error Setting Keychain Item \(item.service).\(item.account)")
            }
        }
    }
}

// MARK: - Keychain Constants
//
enum SimplenoteKeychain {

    /// Extension Token
    ///
    static let extensionAccount = "Main"
    static let extensionService = "SimplenoteIntents"
}
