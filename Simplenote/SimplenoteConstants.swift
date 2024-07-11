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

    static let googleAppEngineBaseURL = "https://app.simplenote.com" as NSString
    static let googleAppEngineHost = "app.simplenote.com"

    /// Simplenote: Current Platform
    ///
    static let simplenotePlatformName = "macOS"

    /// URL(s)
    ///
    static let loginRequestURL              = "https://magic-code-dot-simple-note-hrd.appspot.com/account/request-login" //googleAppEngineBaseURL.appendingPathComponent("/account/request-login")
    static let loginCompletionURL           = "https://magic-code-dot-simple-note-hrd.appspot.com/account/complete-login" //googleAppEngineBaseURL.appendingPathComponent("/account/complete-login")
    static let simplenoteSettingsURL        = googleAppEngineBaseURL.appendingPathComponent("/settings")
    static let simplenoteVerificationURL    = googleAppEngineBaseURL.appendingPathComponent("/account/verify-email/")
    static let simplenoteRequestSignupURL   = googleAppEngineBaseURL.appendingPathComponent("/account/request-signup")
    static let accountDeletionURL           = googleAppEngineBaseURL.appendingPathComponent("/account/request-delete/")
}
