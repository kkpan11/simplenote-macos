import Foundation


// MARK: - AuthenticationMode
//
class AuthenticationMode: NSObject {
    let primaryActionText: String
    
    let secondaryActionText: String?
    
    let switchActionText: String
    let switchActionTip: String
    let switchTargetMode: () -> AuthenticationMode
    
    let isPasswordVisible: Bool
    let isSecondaryActionVisible: Bool
    let isWordPressVisible: Bool
    
    init(primaryActionText: String, secondaryActionText: String?, switchActionText: String, switchActionTip: String, switchTargetMode: @escaping () -> AuthenticationMode, isPasswordVisible: Bool, isSecondaryActionVisible: Bool, isWordPressVisible: Bool) {
        self.primaryActionText = primaryActionText
        self.secondaryActionText = secondaryActionText
        self.switchActionText = switchActionText
        self.switchActionTip = switchActionTip
        self.switchTargetMode = switchTargetMode
        self.isPasswordVisible = isPasswordVisible
        self.isSecondaryActionVisible = isSecondaryActionVisible
        self.isWordPressVisible = isWordPressVisible
    }
}


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
        isWordPressVisible ? CGFloat(72) : .zero
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


extension AuthenticationMode {
    
    /// Auth Mode: Login with Username + Password
    ///
    @objc
    static var loginWithPassword: AuthenticationMode {
        AuthenticationMode(primaryActionText: LoginStrings.primaryAction,
                           secondaryActionText: LoginStrings.secondaryAction,
                           switchActionText: LoginStrings.switchAction,
                           switchActionTip: LoginStrings.switchTip,
                           switchTargetMode: { .signup },
                           isPasswordVisible: true,
                           isSecondaryActionVisible: true,
                           isWordPressVisible: true)
    }

    /// Auth Mode: Login is handled via Magic Links!
    ///
    @objc
    static var loginWithMagicLink: AuthenticationMode {
        AuthenticationMode(primaryActionText: MagicLinkStrings.primaryAction,
                           secondaryActionText: MagicLinkStrings.secondaryAction,
                           switchActionText: MagicLinkStrings.switchAction,
                           switchActionTip: MagicLinkStrings.switchTip,
                           switchTargetMode: { .loginWithPassword },
                           isPasswordVisible: false,
                           isSecondaryActionVisible: true,
                           isWordPressVisible: true)
    }

    /// Auth Mode: SignUp
    ///
    @objc
    static var signup: AuthenticationMode {
        AuthenticationMode(primaryActionText: SignupStrings.primaryAction,
                           secondaryActionText: nil,
                           switchActionText: SignupStrings.switchAction,
                           switchActionTip: SignupStrings.switchTip,
                           switchTargetMode: { .loginWithMagicLink },
                           isPasswordVisible: false,
                           isSecondaryActionVisible: false,
                           isWordPressVisible: false)
    }
}


// MARK: - Localization
//
private enum LoginStrings {
    static let primaryAction    = NSLocalizedString("Log In", comment: "Title of button for logging in")
    static let secondaryAction  = NSLocalizedString("Forgot your Password?", comment: "Forgot Password Button")
    static let switchAction     = NSLocalizedString("Sign Up", comment: "Title of button for signing up")
    static let switchTip        = NSLocalizedString("Need an account?", comment: "Link to create an account")
}

private enum MagicLinkStrings {
    static let primaryAction    = NSLocalizedString("Instantly Log In with Email", comment: "Title of button for logging in")
    static let secondaryAction  = NSLocalizedString("Continue with Password", comment: "Continue with Password Action")
    static let switchAction     = NSLocalizedString("Sign Up", comment: "Title of button for signing up")
    static let switchTip        = NSLocalizedString("Need an account?", comment: "Link to create an account")
}

private enum SignupStrings {
    static let primaryAction    = NSLocalizedString("Sign Up", comment: "Title of button for signing up")
    static let switchAction     = NSLocalizedString("Log In", comment: "Title of button for logging in up")
    static let switchTip        = NSLocalizedString("Already have an account?", comment: "Link to sign in to an account")
}
