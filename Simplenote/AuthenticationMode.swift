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

    let isIntroView: Bool

    init(title: String,
         header: String? = nil,
         inputElements: AuthenticationInputElements,
         actions: [AuthenticationActionDescriptor],
         primaryActionAnimationText: String,
         isIntroView: Bool = false) {
        self.title = title
        self.header = header
        self.inputElements = inputElements
        self.actions = actions
        self.primaryActionAnimationText =  primaryActionAnimationText
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
    static func loginWithPassword(header: String? = nil) -> AuthenticationMode {
        AuthenticationMode(title: NSLocalizedString("Log In with Password", comment: "LogIn Interface Title"),
                           header: header,
                           inputElements: [.password],
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
                            AuthenticationActionDescriptor(name: .tertiary,
                                                           selector: #selector(AuthViewController.wordpressSSOAction),
                                                           text: LoginStrings.wordpressAction)
                           ],
                           primaryActionAnimationText: MagicLinkStrings.primaryAnimationText)
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
    static let primaryAction        = NSLocalizedString("Log In", comment: "Title of button for logging in")
    static let primaryAnimationText = NSLocalizedString("Logging In...", comment: "Title of button for logging in")
    static let secondaryAction      = NSLocalizedString("Forgot your Password?", comment: "Forgot Password Button")
    static let switchAction         = NSLocalizedString("Sign Up", comment: "Title of button for signing up")
    static let switchTip            = NSLocalizedString("Need an account?", comment: "Link to create an account")
    static let wordpressAction      = NSLocalizedString("Log in with WordPress.com", comment: "Title to use wordpress login instead of email")
}

private enum MagicLinkStrings {
    static let primaryAction        = NSLocalizedString("Instantly Log In with Email", comment: "Title of button for logging in")
    static let primaryAnimationText = NSLocalizedString("Requesting Email...", comment: "Title of button for logging in")
    static let secondaryAction      = NSLocalizedString("Continue with Password", comment: "Continue with Password Action")
    static let switchAction         = NSLocalizedString("Sign Up", comment: "Title of button for signing up")
    static let switchTip            = NSLocalizedString("Need an account?", comment: "Link to create an account")
}

private enum SignupStrings {
    static let primaryAction        = NSLocalizedString("Sign Up", comment: "Title of button for signing up")
    static let primaryAnimationText = NSLocalizedString("Signing Up...", comment: "Title of button for logging in")
    static let switchAction         = NSLocalizedString("Log In", comment: "Title of button for logging in up")
    static let switchTip            = NSLocalizedString("Already have an account?", comment: "Link to sign in to an account")
}
