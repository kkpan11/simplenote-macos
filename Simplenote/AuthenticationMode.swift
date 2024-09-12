import Foundation

// MARK: - State
//
@objcMembers
class AuthenticationState: NSObject {
    var username = String()
    var password = String()
    var code = String()
}

// MARK: - Authentication Elements
//
struct AuthenticationInputElements: OptionSet, Hashable {
    let rawValue: UInt

    static let username         = AuthenticationInputElements(rawValue: 1 << 0)
    static let password         = AuthenticationInputElements(rawValue: 1 << 1)
    static let code             = AuthenticationInputElements(rawValue: 1 << 2)
    static let actionSeparator  = AuthenticationInputElements(rawValue: 1 << 3)
}

// MARK: - Authentication Actions
//
enum AuthenticationActionName {
    case primary
    case secondary
    case tertiary
    case quaternary
}

struct AuthenticationActionDescriptor {
    let name: AuthenticationActionName
    let selector: Selector
    let text: String?
    let attributedText: NSAttributedString?

    init(name: AuthenticationActionName, selector: Selector, text: String?, attributedText: NSAttributedString? = nil) {
        self.name = name
        self.selector = selector
        self.text = text
        self.attributedText = attributedText
    }
}

// MARK: - AuthenticationMode
//
class AuthenticationMode: NSObject {
    let title: String
    let header: String?
    let inputElements: AuthenticationInputElements
    let actions: [AuthenticationActionDescriptor]
    let primaryActionAnimationText: String
    let rateLimitingFallbackMode: (() -> AuthenticationMode)?
    let isIntroView: Bool

    init(title: String,
         header: String? = nil,
         inputElements: AuthenticationInputElements,
         actions: [AuthenticationActionDescriptor],
         primaryActionAnimationText: String,
         rateLimitingFallbackMode: (() -> AuthenticationMode)? = nil,
         isIntroView: Bool = false) {
        self.title = title
        self.header = header
        self.inputElements = inputElements
        self.actions = actions
        self.primaryActionAnimationText =  primaryActionAnimationText
        self.rateLimitingFallbackMode = rateLimitingFallbackMode
        self.isIntroView = isIntroView
    }
}

// MARK: - Convenience Properties
//
extension AuthenticationMode {
    func action(withName name: AuthenticationActionName) -> AuthenticationActionDescriptor? {
        actions.first(where: { $0.name == name })
    }
}


// MARK: - Public Properties
//
extension AuthenticationMode {

    func buildHeaderText(email: String) -> NSAttributedString? {
        guard let header = header?.replacingOccurrences(of: "{{EMAIL}}", with: email) else {
            return nil
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        return NSMutableAttributedString(string: header, attributes: [
            .font: NSFont.systemFont(ofSize: 16, weight: .regular),
            .paragraphStyle: paragraphStyle
        ], highlighting: email, highlightAttributes: [
            .font: NSFont.systemFont(ofSize: 16, weight: .bold)
        ])
    }
}

// MARK: - Static Properties
//
extension AuthenticationMode {
    @objc
    static var onboarding: AuthenticationMode {
        return AuthenticationMode(title: "Onboarding",
                                  header: nil,
                                  inputElements: [],
                                  actions: [
                                    AuthenticationActionDescriptor(name: .primary,
                                                                   selector: #selector(AuthViewController.pushSignupView),
                                                                   text: SignupStrings.primaryAction),
                                    AuthenticationActionDescriptor(name: .secondary,
                                                                   selector: #selector(AuthViewController.pushEmailLoginView),
                                                                   text: LoginStrings.primaryAction.uppercased())
                                  ],
                                  primaryActionAnimationText: SignupStrings.primaryAnimationText,
                                  isIntroView: true)
    }

    /// Auth Mode: Login with Username + Password
    ///
    static var loginWithPassword: AuthenticationMode {
        buildLoginWithPasswordMode(header: LoginStrings.loginWithEmailEmailHeader)
    }

    static var loginWithUsernameAndPassword: AuthenticationMode {
        buildLoginWithPasswordMode(header: nil, includeUsername: true)
    }

    /// Auth Mode: Login with Username + Password + Rate Limiting Header
    ///
    static var loginWithPasswordRateLimited: AuthenticationMode {
        buildLoginWithPasswordMode(header: LoginStrings.loginWithEmailLimitHeader)
    }

    /// Builds the loginWithPassword Mode with the specified Header
    ///
    private static func buildLoginWithPasswordMode(header: String?, includeUsername: Bool = false) -> AuthenticationMode {
        let inputElements: AuthenticationInputElements = includeUsername ? [.username, .password] : [.password]
        return AuthenticationMode(title: NSLocalizedString("Log In with Password", comment: "LogIn Interface Title"),
                           header: header,
                           inputElements: inputElements,
                           actions: [
                            AuthenticationActionDescriptor(name: .primary,
                                                           selector: #selector(AuthViewController.pressedLogInWithPassword),
                                                           text: LoginStrings.primaryAction),
                            AuthenticationActionDescriptor(name: .secondary,
                                                           selector: #selector(AuthViewController.openForgotPasswordURL),
                                                           text: LoginStrings.secondaryAction)
                           ],
                           primaryActionAnimationText: LoginStrings.primaryAnimationText)
    }

    /// Auth Mode: Login is handled via Magic Links!
    /// Requests a Login Code
    ///
    @objc
    static var requestLoginCode: AuthenticationMode {
        AuthenticationMode(title: NSLocalizedString("Log In", comment: "LogIn Interface Title"),
                           inputElements: [.username, .actionSeparator],
                           actions: [
                            AuthenticationActionDescriptor(name: .primary,
                                                           selector: #selector(AuthViewController.pressedLoginWithMagicLink),
                                                           text: MagicLinkStrings.primaryAction),
                            AuthenticationActionDescriptor(name: .secondary,
                                                           selector: #selector(AuthViewController.pushUsernameAndPasswordView),
                                                           text: nil,
                                                           attributedText: LoginStrings.usernameAndPasswordOption),
                            AuthenticationActionDescriptor(name: .tertiary,
                                                           selector: #selector(AuthViewController.wordpressSSOAction),
                                                           text: LoginStrings.wordpressAction)
                           ],
                           primaryActionAnimationText: MagicLinkStrings.primaryAnimationText,
                           rateLimitingFallbackMode: {
                                AuthenticationMode.loginWithPasswordRateLimited
                            })
    }

    /// Auth Mode: SignUp
    ///
    @objc
    static var signup: AuthenticationMode {
        AuthenticationMode(title: NSLocalizedString("Sign Up", comment: "SignUp Interface Title"),
                           inputElements: [.username],
                           actions: [
                            AuthenticationActionDescriptor(name: .primary,
                                                           selector: #selector(AuthViewController.pressedSignUp),
                                                           text: SignupStrings.primaryAction)
                           ],
                           primaryActionAnimationText: SignupStrings.primaryAnimationText)
    }

    /// Login with Code: Submit Code + Authenticate the user
    ///
    static var loginWithCode: AuthenticationMode {
        AuthenticationMode(title: NSLocalizedString("Enter Code", comment: "LogIn Interface Title"),
                           header: NSLocalizedString("We've sent a code to {{EMAIL}}. The code will be valid for a few minutes.", comment: "Header for the Login with Code UI. Please preserve the {{EMAIL}} string as is!"),
                           inputElements: [.code, .actionSeparator],
                           actions: [
                            AuthenticationActionDescriptor(name: .primary,
                                                           selector: #selector(AuthViewController.performLogInWithCode),
                                                           text: NSLocalizedString("Log In", comment: "LogIn Interface Title")),
                            AuthenticationActionDescriptor(name: .quaternary,
                                                           selector: #selector(AuthViewController.pushPasswordView),
                                                           text: NSLocalizedString("Enter password", comment: "Enter Password fallback Action")),
                           ],
                           primaryActionAnimationText: LoginStrings.primaryAnimationText)
    }

}


// MARK: - Localization
//
private enum LoginStrings {
    static let primaryAction        = NSLocalizedString("Log in", comment: "Title of button for logging in")
    static let primaryAnimationText = NSLocalizedString("Logging in...", comment: "Title of button for logging in")
    static let secondaryAction      = NSLocalizedString("Forgot your password?", comment: "Forgot Password Button")
    static let wordpressAction      = NSLocalizedString("Log in with WordPress.com", comment: "Title to use wordpress login instead of email")
    static let loginWithEmailEmailHeader = NSLocalizedString("Enter the password for the account {{EMAIL}}", comment: "Header for Login With Password. Please preserve the {{EMAIL}} substring")
    static let loginWithEmailLimitHeader = NSLocalizedString("Log in with email failed, please enter the password for {{EMAIL}}", comment: "Header for Enter Password UI, when the user performed too many requests")

    /// Returns a formatted Secondary Action String for Optional Username and password login
    ///
    static var usernameAndPasswordOption: NSAttributedString {
        let output = NSMutableAttributedString(string: String(), attributes: [
            .font: NSFont.preferredFont(forTextStyle: .subheadline)
        ])

        let prefix = NSLocalizedString("We'll email you a code to log in, \nor you can", comment: "Option to login with username and password *PREFIX*: printed in dark color")
        let suffix = NSLocalizedString("log in manually.", comment: "Option to login with username and password *SUFFIX*: Concatenated with a space, after the PREFIX, and printed in blue")

        output.append(string: prefix, foregroundColor: NSColor(studioColor: ColorStudio.gray60))
        output.append(string: " ")
        output.append(string: suffix, foregroundColor: NSColor(studioColor: ColorStudio.spBlue60))

        return output
    }

}

private enum MagicLinkStrings {
    static let primaryAction        = NSLocalizedString("Log in with email", comment: "Title of button for logging in")
    static let primaryAnimationText = NSLocalizedString("Requesting email...", comment: "Title of button for logging in")
    static let secondaryAction      = NSLocalizedString("Continue with password", comment: "Continue with Password Action")
}

private enum SignupStrings {
    static let primaryAction        = NSLocalizedString("Sign up", comment: "Title of button for signing up")
    static let primaryAnimationText = NSLocalizedString("Signing up...", comment: "Title of button for logging in")
}
