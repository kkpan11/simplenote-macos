import Foundation


// MARK: - AuthenticationMode
//
class AuthenticationMode: NSObject {
    let title: String
    let header: String?

    let primaryActionText: String
    let primaryActionAnimationText: String
    let primaryActionSelector: Selector
    
    let secondaryActionText: String?
    let secondaryActionSelector: Selector?

    let switchTargetMode: () -> AuthenticationMode
    
    let isPasswordVisible: Bool
    let isSecondaryActionVisible: Bool
    let isWordPressVisible: Bool
    let showActionSeparator: Bool
    let isIntroView: Bool

    init(title: String,
         header: String? = nil,
         primaryActionText: String,
         primaryActionAnimationText: String,
         primaryActionSelector: Selector,
         secondaryActionText: String?,
         secondaryActionSelector: Selector?,
         switchTargetMode: @escaping () -> AuthenticationMode,
         isPasswordVisible: Bool,
         isSecondaryActionVisible: Bool,
         isWordPressVisible: Bool,
         showActionSeparator: Bool,
         isIntroView: Bool = false) {
        self.title = title
        self.header = header
        self.primaryActionText = primaryActionText
        self.primaryActionAnimationText =  primaryActionAnimationText
        self.primaryActionSelector = primaryActionSelector
        self.secondaryActionText = secondaryActionText
        self.secondaryActionSelector = secondaryActionSelector
        self.switchTargetMode = switchTargetMode
        self.isPasswordVisible = isPasswordVisible
        self.isSecondaryActionVisible = isSecondaryActionVisible
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
    
    var secondaryActionFieldHeight: CGFloat {
        isSecondaryActionVisible ? CGFloat(20) : .zero
    }
    
    var wordPressSSOFieldHeight: CGFloat {
        isWordPressVisible ? CGFloat(40) : .zero
    }
    
    var passwordFieldAlpha: CGFloat {
        isPasswordVisible ? AppKitConstants.alpha1_0 : AppKitConstants.alpha0_0
    }
    
    var secondaryActionFieldAlpha: CGFloat {
        isSecondaryActionVisible ? AppKitConstants.alpha1_0 : AppKitConstants.alpha0_0
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
                           primaryActionText: SignupStrings.primaryAction,
                           primaryActionAnimationText: SignupStrings.primaryAnimationText,
                           primaryActionSelector: #selector(AuthViewController.pushSignupView),
                           secondaryActionText: LoginStrings.primaryAction,
                           secondaryActionSelector: #selector(AuthViewController.pushEmailLoginView),
                           switchTargetMode: { .requestLoginCode }, isPasswordVisible: false,
                           isSecondaryActionVisible: true,
                           isWordPressVisible: false,
                           showActionSeparator: false,
                                  isIntroView: true)
    }

    /// Auth Mode: Login with Username + Password
    ///
    static func loginWithPassword(header: String? = nil) -> AuthenticationMode {
        AuthenticationMode(title: NSLocalizedString("Log In with Password", comment: "LogIn Interface Title"),
                           header: header,
                           primaryActionText: LoginStrings.primaryAction,
                           primaryActionAnimationText: LoginStrings.primaryAnimationText,
                           primaryActionSelector: #selector(AuthViewController.pressedLogInWithPassword),
                           secondaryActionText: LoginStrings.secondaryAction,
                           secondaryActionSelector: #selector(AuthViewController.openForgotPasswordURL),
                           switchTargetMode: { .signup },
                           isPasswordVisible: true,
                           isSecondaryActionVisible: true,
                           isWordPressVisible: true,
                           showActionSeparator: true)
    }

    /// Auth Mode: Login is handled via Magic Links!
    /// Requests a Login Code
    ///
    @objc
    static var requestLoginCode: AuthenticationMode {
        AuthenticationMode(title: NSLocalizedString("Log In", comment: "LogIn Interface Title"),
                           primaryActionText: MagicLinkStrings.primaryAction,
                           primaryActionAnimationText: MagicLinkStrings.primaryAnimationText,
                           primaryActionSelector: #selector(AuthViewController.pressedLoginWithMagicLink),
                           secondaryActionText: MagicLinkStrings.secondaryAction,
                           secondaryActionSelector: #selector(AuthViewController.switchToPasswordAuth),
                           switchTargetMode: { .signup },
                           isPasswordVisible: false,
                           isSecondaryActionVisible: true,
                           isWordPressVisible: true,
                           showActionSeparator: true)
    }

    /// Auth Mode: SignUp
    ///
    @objc
    static var signup: AuthenticationMode {
        AuthenticationMode(title: NSLocalizedString("Sign Up", comment: "SignUp Interface Title"),
                           primaryActionText: SignupStrings.primaryAction,
                           primaryActionAnimationText: SignupStrings.primaryAnimationText,
                           primaryActionSelector: #selector(AuthViewController.pressedSignUp),
                           secondaryActionText: SignupStrings.switchAction,
                           secondaryActionSelector: #selector(AuthViewController.pushEmailLoginView),
                           switchTargetMode: { .requestLoginCode },
                           isPasswordVisible: false,
                           isSecondaryActionVisible: true,
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
