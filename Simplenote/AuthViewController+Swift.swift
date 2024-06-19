import Foundation

// MARK: - AuthViewController: Interface Initialization
//
extension AuthViewController {

    @objc
    func setupInterface() {
        // Error Label
        errorField.stringValue = ""
        errorField.textColor = .red

        // Fields
        usernameField.placeholderString = Localization.emailPlaceholder
        usernameField.delegate = self

        passwordField.placeholderString = Localization.passwordPlaceholder
        passwordField.delegate = self

        // Secondary Action
        secondaryActionButton.contentTintColor = .simplenoteBrandColor

        // Toggle Signup: Tip
        switchTipField.textColor = .simplenoteTertiaryTextColor

        // Toggle Signup: Action
        switchActionButton.contentTintColor = .simplenoteBrandColor

        // WordPress SSO
        wordPressSSOButton.image = NSImage(named: .wordPressLogo)?.tinted(with: .simplenoteBrandColor)
        wordPressSSOButton.title = Localization.dotcomSSOAction
        wordPressSSOButton.contentTintColor = .simplenoteTertiaryTextColor
    }
}

// MARK: - Dynamic Properties
//
extension AuthViewController {

    @objc
    var usernameText: String {
        usernameField.stringValue?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    @objc
    var passwordText: String {
        passwordField.stringValue?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
}

// MARK: - Refreshing
//
extension AuthViewController {

    @objc(refreshInterfaceWithAnimation:)
    func refreshInterface(animated: Bool) {
        clearAuthenticationError()
        refreshButtonTitles()
        refreshEnabledComponents()
        refreshVisibleComponents(animated: animated)
    }

    func refreshButtonTitles() {
        actionButton.title          = mode.primaryActionText
        secondaryActionButton.title = mode.secondaryActionText?.uppercased() ?? ""
        switchTipField.stringValue  = mode.switchActionTip.uppercased()
        switchActionButton.title    = mode.switchActionText.uppercased()
    }

    /// Makes sure unused components (in the current mode) are effectively disabled
    ///
    func refreshEnabledComponents() {
        passwordField.isEnabled         = mode.isPasswordVisible
        secondaryActionButton.isEnabled = mode.isSecondaryActionVisible
        wordPressSSOButton.isEnabled    = mode.isWordPressVisible
    }

    /// Shows / Hides relevant components, based on the specified state
    ///
    func refreshVisibleComponents(animated: Bool) {
        if animated {
            refreshVisibleComponentsWithAnimation()
        } else {
            refreshVisibleComponentsWithoutAnimation()
        }
    }

    /// Shows / Hides relevant components, based on the specified state
    /// - Note: Trust me on this one. It's cleaner to have specific methods, rather than making a single one support the `animated` flag.
    ///         Notice that AppKit requires us to go thru `animator()`.
    ///
    func refreshVisibleComponentsWithoutAnimation() {
        passwordFieldHeightConstraint.constant  = mode.passwordFieldHeight
        secondaryActionHeightConstraint.constant = mode.secondaryActionFieldHeight
        wordPressSSOHeightConstraint.constant   = mode.wordPressSSOFieldHeight

        passwordField.alphaValue                = mode.passwordFieldAlpha
        secondaryActionButton.alphaValue        = mode.secondaryActionFieldAlpha
        wordPressSSOButton.alphaValue           = mode.wordPressSSOFieldAlpha
    }

    /// Animates Visible / Invisible components, based on the specified state
    ///
    func refreshVisibleComponentsWithAnimation() {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = AppKitConstants.duration0_2

            passwordFieldHeightConstraint.animator().constant   = mode.passwordFieldHeight
            secondaryActionHeightConstraint.animator().constant = mode.secondaryActionFieldHeight
            wordPressSSOHeightConstraint.animator().constant    = mode.wordPressSSOFieldHeight

            passwordField.alphaValue            = mode.passwordFieldAlpha
            secondaryActionButton.alphaValue    = mode.secondaryActionFieldAlpha
            wordPressSSOButton.alphaValue       = mode.wordPressSSOFieldAlpha
            
            view.layoutSubtreeIfNeeded()
        }
    }

    /// Drops any Errors onscreen
    ///
    @objc
    func clearAuthenticationError() {
        errorField.stringValue = ""
    }

    /// Marks the Username Field as the First Responder
    ///
    @objc
    func ensureUsernameIsFirstResponder() {
        usernameField?.textField.becomeFirstResponder()
        view.needsDisplay = true
    }
}

// MARK: - IBAction Handlers
//
extension AuthViewController {

    @objc
    func didUpdateAuthenticationMode() {
        guard isViewLoaded else {
            return
        }

        refreshInterface(animated: true)
        ensureUsernameIsFirstResponder()
    }
    
    @IBAction
    func performMainAction(_ sender: Any) {
        performSelector(onMainThread: mode.primaryActionSelector, with: nil, waitUntilDone: false)
    }
    
    @IBAction
    func performSecondaryAction(_ sender: Any) {
        guard let secondaryActionSelector = mode.secondaryActionSelector else {
            return
        }
        
        performSelector(onMainThread: secondaryActionSelector, with: nil, waitUntilDone: false)
    }
}


// MARK: - Handlers
//
extension AuthViewController {

    @IBAction
    func switchToPasswordAuth(_ sender: Any) {
        mode = .loginWithPassword
    }
    
    @objc
    func performSignupRequest() {
        startActionAnimation()
        setInterfaceEnabled(false)

        let email = usernameText
        SignupRemote().requestSignup(email: email) { [weak self] (result) in
            guard let self = `self` else {
                return
            }

            switch result {
            case .success:
                self.presentSignupVerification(email: email)
            case .failure(let result):
                self.showAuthenticationError(forCode: result.statusCode, responseString: nil)
            }

            self.stopActionAnimation()
            self.setInterfaceEnabled(true)
        }
    }
    
    @objc
    func performLoginWithEmailRequest() {
        Task { @MainActor in
            await performLoginWithEmailRequestInTask()
        }
    }
     
    func performLoginWithEmailRequestInTask() async {
        defer {
            stopActionAnimation()
            setInterfaceEnabled(true)
        }
        
        startActionAnimation()
        setInterfaceEnabled(false)

        do {
            let remote = LoginRemote()
            try await remote.requestLoginEmail(email: self.usernameText)
// TODO: Verification Success
        } catch {
            let statusCode = (error as? RemoteError)?.statusCode ?? .zero
            self.showAuthenticationError(forCode: statusCode, responseString: nil)
        }
    }
    
    @IBAction
    func handleNewlineInField(_ field: NSControl) {
        if field.isEqual(passwordField.textField) {
            performMainAction(field)
            return
        }
        
        if field.isEqual(usernameField.textField), mode.isPasswordVisible == false {
            performMainAction(field)
        }
    }
}


// MARK: - Animations
//
extension AuthViewController {
    
    @objc
    func startActionAnimation() {
        actionButton.title = mode.primaryActionAnimationText
        actionProgress.startAnimation(nil)
    }

    @objc
    func stopActionAnimation() {
        actionButton.title = mode.primaryActionText
        actionProgress.stopAnimation(nil)
    }
}


// MARK: - Presenting!
//
extension AuthViewController {

    func presentSignupVerification(email: String) {
        let vc = SignupVerificationViewController(email: email, authenticator: authenticator)
        view.window?.transition(to: vc)
    }
}

// MARK: - Login Error Handling
//
extension AuthViewController {
    @objc
    func showCompromisedPasswordAlert(for window: NSWindow, completion: @escaping (NSApplication.ModalResponse) -> Void) {
        let alert = NSAlert()
        alert.messageText = Localization.compromisedPasswordAlert
        alert.informativeText = Localization.compromisedPasswordMessage
        alert.addButton(withTitle: Localization.changePasswordAction)
        alert.addButton(withTitle: Localization.dismissChangePasswordAction)

        alert.beginSheetModal(for: window, completionHandler: completion)
    }

    @objc
    func showUnverifiedEmailAlert(for window: NSWindow, completion: @escaping (NSApplication.ModalResponse) -> Void) {
        let alert = NSAlert()
        alert.messageText = Localization.unverifiedMessageText
        alert.informativeText = Localization.unverifiedInformativeText
        alert.addButton(withTitle: Localization.unverifiedActionText)
        alert.addButton(withTitle: Localization.cancelText)

        alert.beginSheetModal(for: window, completionHandler: completion)
    }

    @objc
    func sendVerificationMessage(for email: String, inWindow window: NSWindow) {
        setInterfaceEnabled(false)
        let progressIndicator = NSProgressIndicator.addProgressIndicator(to: view)

        AccountRemote().verify(email: email) { result in
            self.setInterfaceEnabled(true)
            progressIndicator.removeFromSuperview()

             var alert: NSAlert
             switch result {
             case .success:
                alert = NSAlert(messageText: Localization.verificationSentTitle, informativeText: String(format: Localization.verificationSentTemplate, email))
             case .failure:
                alert = NSAlert(messageText: Localization.unverifriedErrorTitle, informativeText: Localization.unverifiedErrorMessage)
             }
            alert.addButton(withTitle: Localization.cancelText)
            alert.beginSheetModal(for: window, completionHandler: nil)
        }
    }
}


// MARK: - Localization
//
private enum Localization {
    static let emailPlaceholder = NSLocalizedString("Email", comment: "Placeholder text for login field")
    static let passwordPlaceholder = NSLocalizedString("Password", comment: "Placeholder text for password field")
    static let dotcomSSOAction = NSLocalizedString("Log in with WordPress.com", comment: "button title for wp.com sign in button")
    static let compromisedPasswordAlert = NSLocalizedString("Compromised Password", comment: "Compromised passsword alert title")
    static let compromisedPasswordMessage = NSLocalizedString("This password has appeared in a data breach, which puts your account at high risk of compromise. To protect your data, you'll need to update your password before being able to log in again.", comment: "Compromised password alert message")
    static let changePasswordAction = NSLocalizedString("Change Password", comment: "Change password action")
    static let dismissChangePasswordAction = NSLocalizedString("Cancel", comment: "Dismiss change password alert action")
    static let unverifiedInformativeText = NSLocalizedString("You must verify your email before being able to login.", comment: "Erro for un verified email")
    static let unverifiedMessageText = NSLocalizedString("Account Verification Required", comment: "Email verification required alert title")
    static let cancelText = NSLocalizedString("Ok", comment: "Email unverified alert dismiss")
    static let unverifiedActionText = NSLocalizedString("Resend Verification Email", comment: "Send email verificaiton action")
    static let unverifriedErrorTitle = NSLocalizedString("Request Error", comment: "Request error alert title")
    static let unverifiedErrorMessage = NSLocalizedString("There was an preparing your verification email, please try again later", comment: "Request error alert message")
    static let verificationSentTitle = NSLocalizedString("Check your Email", comment: "Vefification sent alert title")
    static let verificationSentTemplate = NSLocalizedString("We’ve sent a verification email to %1$@. Please check your inbox and follow the instructions.", comment: "Confirmation that an email has been sent")
}
