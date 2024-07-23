import Foundation

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
    let actions: [AuthenticationActionDescriptor]

    let primaryActionAnimationText: String

    let switchTargetMode: () -> AuthenticationMode
    
    let isPasswordVisible: Bool
    let isWordPressVisible: Bool
    let showActionSeparator: Bool
    let isIntroView: Bool

    init(title: String,
         header: String? = nil,
         actions: [AuthenticationActionDescriptor],
         primaryActionAnimationText: String,
         switchTargetMode: @escaping () -> AuthenticationMode,
         isPasswordVisible: Bool,
         isWordPressVisible: Bool,
         showActionSeparator: Bool,
         isIntroView: Bool = false) {
        self.title = title
        self.header = header
        self.actions = actions
        self.primaryActionAnimationText =  primaryActionAnimationText
        self.switchTargetMode = switchTargetMode
        self.isPasswordVisible = isPasswordVisible
        self.isWordPressVisible = isWordPressVisible
        self.showActionSeparator = showActionSeparator
        self.isIntroView = isIntroView
    }
}

// MARK: - Dynamic Properties
//
extension AuthenticationMode {
    
    @objc
    func nextMode() -> AuthenticationMode {
        switchTargetMode()
    }
    
    var passwordFieldHeight: CGFloat {
        isPasswordVisible ? CGFloat(40) : .zero
    }
    
    var wordPressSSOFieldHeight: CGFloat {
        isWordPressVisible ? CGFloat(40) : .zero
    }
    
    var passwordFieldAlpha: CGFloat {
        isPasswordVisible ? AppKitConstants.alpha1_0 : AppKitConstants.alpha0_0
    }

    var wordPressSSOFieldAlpha: CGFloat {
        isWordPressVisible ? AppKitConstants.alpha1_0 : AppKitConstants.alpha0_0
    }
}


// MARK: - Static Properties
//
extension AuthenticationMode {
    @objc
    static var onboarding: AuthenticationMode {
        return AuthenticationMode(title: "Onboarding",
                                  header: nil,
                                  actions: [
                                    AuthenticationActionDescriptor(name: .primary,
                                                                   selector: #selector(AuthViewController.pushSignupView),
                                                                   text: SignupStrings.primaryAction),
                                    AuthenticationActionDescriptor(name: .secondary,
                                                                   selector: #selector(AuthViewController.pushEmailLoginView),
                                                                   text: LoginStrings.primaryAction)
                                  ],

                           primaryActionAnimationText: SignupStrings.primaryAnimationText,
                           switchTargetMode: { .requestLoginCode }, isPasswordVisible: false,
                           isWordPressVisible: false,
                           showActionSeparator: false,
                                  isIntroView: true)
    }

    /// Auth Mode: Login with Username + Password
    ///
    static func loginWithPassword(header: String? = nil) -> AuthenticationMode {
        AuthenticationMode(title: NSLocalizedString("Log In with Password", comment: "LogIn Interface Title"),
                           header: header,
                           actions: [
                            AuthenticationActionDescriptor(name: .primary,
                                                           selector: #selector(AuthViewController.pressedLogInWithPassword),
                                                           text: LoginStrings.primaryAction),
                            AuthenticationActionDescriptor(name: .secondary,
                                                           selector: #selector(AuthViewController.openForgotPasswordURL),
                                                           text: LoginStrings.secondaryAction)
                           ],
                           primaryActionAnimationText: LoginStrings.primaryAnimationText,
                           switchTargetMode: { .signup },
                           isPasswordVisible: true,
                           isWordPressVisible: true,
                           showActionSeparator: true)
    }

    /// Auth Mode: Login is handled via Magic Links!
    /// Requests a Login Code
    ///
    @objc
    static var requestLoginCode: AuthenticationMode {
        AuthenticationMode(title: NSLocalizedString("Log In", comment: "LogIn Interface Title"),
                           actions: [
                            AuthenticationActionDescriptor(name: .primary, 
                                                           selector: #selector(AuthViewController.pressedLoginWithMagicLink),
                                                           text: MagicLinkStrings.primaryAction),
                            AuthenticationActionDescriptor(name: .secondary,
                                                           selector: #selector(AuthViewController.switchToPasswordAuth),
                                                           text: MagicLinkStrings.secondaryAction),
                            AuthenticationActionDescriptor(name: .tertiary,
                                                           selector: #selector(AuthViewController.wordpressSSOAction), text: LoginStrings.wordpressAction)
                           ],
                           primaryActionAnimationText: MagicLinkStrings.primaryAnimationText,
                           switchTargetMode: { .signup },
                           isPasswordVisible: false,
                           isWordPressVisible: true,
                           showActionSeparator: true)
    }

    /// Auth Mode: SignUp
    ///
    @objc
    static var signup: AuthenticationMode {
        AuthenticationMode(title: NSLocalizedString("Sign Up", comment: "SignUp Interface Title"),
                           actions: [
                            AuthenticationActionDescriptor(name: .primary,
                                                           selector: #selector(AuthViewController.pressedSignUp),
                                                           text: SignupStrings.primaryAction)
                           ],
                           primaryActionAnimationText: SignupStrings.primaryAnimationText,
                           switchTargetMode: { .requestLoginCode },
                           isPasswordVisible: false,
                           isWordPressVisible: false,
                           showActionSeparator: false)
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
