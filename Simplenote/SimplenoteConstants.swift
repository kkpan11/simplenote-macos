import Foundation

// MARK: - Simplenote Constants!
//
@objcMembers
class SimplenoteConstants: NSObject {

    /// You shall not pass (!!)
    ///
    private override init() { }

    /// Tag(s) Max Length
    ///
    static let maximumTagLength = 256

    /// Simplenote: Scheme
    ///
    static let simplenoteScheme = "simplenote"

    /// Simplenote: Interlink
    ///
    static let simplenoteInterlinkHost = "note"
    static let simplenoteInterlinkMaxTitleLength = 150

    static let currentEngineBaseURL = "https://app.simplenote.com" as NSString

    /// Simplenote: Current Platform
    ///
    static let simplenotePlatformName = "macOS"

    /// URL(s)
    ///
    static let loginRequestURL              = currentEngineBaseURL.appendingPathComponent("/account/request-login")
    static let loginCompletionURL           = currentEngineBaseURL.appendingPathComponent("/account/complete-login")
    static let simplenoteSettingsURL        = currentEngineBaseURL.appendingPathComponent("/settings")
    static let simplenoteVerificationURL    = currentEngineBaseURL.appendingPathComponent("/account/verify-email/")
    static let simplenoteRequestSignupURL   = currentEngineBaseURL.appendingPathComponent("/account/request-signup")
    static let accountDeletionURL           = currentEngineBaseURL.appendingPathComponent("/account/request-delete/")
}
