import Foundation

// MARK: - AuthViewController: Interface Initialization
//
extension AuthViewController {

    @objc
    func setupInterface() {
        if state == nil {
            state = AuthenticationState()
        }

        simplenoteTitleView.stringValue = "Simplenote"
        simplenoteSubTitleView.textColor = .simplenoteGray50Color
        simplenoteSubTitleView.stringValue = NSLocalizedString("The simplest way to keep notes.", comment: "Simplenote subtitle")
        // Error Label
        errorField.stringValue = ""
        errorField.textColor = .red

        // Fields
        usernameField.placeholderString = Localization.emailPlaceholder
        usernameField.delegate = self

        passwordField.placeholderString = Localization.passwordPlaceholder
        passwordField.delegate = self

        codeTextField.placeholderString = Localization.codePlaceholder
        codeTextField.delegate = self

        // Secondary Action
        secondaryActionButton.contentTintColor = .simplenoteBrandColor

        // tertiary button
        tertiaryButton.contentTintColor = .white
        tertiaryButton.wantsLayer = true
        tertiaryButton.layer?.backgroundColor = NSColor.simplenoteWPBlue50Color.cgColor
        tertiaryButton.layer?.cornerRadius = 5

        // quarternary button
        quarternaryButtonView.wantsLayer = true
        quarternaryButtonView.layer?.borderWidth = 2
        quarternaryButtonView.layer?.borderColor = .black
        quarternaryButtonView.layer?.cornerRadius = 5

        setupActionsSeparatorView()
        setupAdditionalButtons()
    }

    private func setupActionsSeparatorView() {
        leadingSeparatorView.wantsLayer = true
        leadingSeparatorView.layer?.backgroundColor = NSColor.lightGray.cgColor
        trailingSeparatorView.wantsLayer = true
        trailingSeparatorView.layer?.backgroundColor = NSColor.lightGray.cgColor

        separatorLabel.textColor = .lightGray
    }

    private func setupAdditionalButtons() {
        let modeActions = mode.actions

        tertiaryButtonContainerView.isHidden = !modeActions.contains(where: { $0.name == .tertiary })
        quarternaryButtonView.isHidden = !modeActions.contains(where: { $0.name == .quaternary })
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
    
    var authWindowController: AuthWindowController? {
        view.window?.windowController as? AuthWindowController
    }

    /// # All of the Action Views
    ///
    private var allActionViews: [NSButton] {
        [actionButton, secondaryActionButton, tertiaryButton, quarternaryButton]
    }
}

// MARK: - Refreshing
//
extension AuthViewController {

    @objc(refreshInterfaceWithAnimation:)
    func refreshInterface(animated: Bool) {
        clearAuthenticationError()
        refreshActionViews()
        refreshInputViews()
        refreshVisibleComponents(animated: animated)
    }

    private func refreshActionViews() {
        let viewMap: [AuthenticationActionName: NSButton] = [
            .primary: actionButton,
            .secondary: secondaryActionButton,
            .tertiary: tertiaryButton,
            .quaternary: quarternaryButton
        ]

        allActionViews.forEach({
            $0.isHidden = true
            $0.isEnabled = false
        })

        for descriptor in mode.actions {
            guard let actionView = viewMap[descriptor.name] else {
                assertionFailure()
                continue
            }

            if let title = descriptor.text {
                actionView.title = title
            }

            actionView.action = descriptor.selector
            actionView.target = self
            actionView.isHidden = false
            actionView.isEnabled = true
        }
    }

    private func refreshInputViews() {
        let inputElements = mode.inputElements

        usernameField.isHidden          = !inputElements.contains(.username)
        passwordField.isHidden          = !inputElements.contains(.password)
        codeTextField.isHidden          = !inputElements.contains(.code)
        actionsSeparatorView.isHidden   = !inputElements.contains(.actionSeparator)

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

        passwordField.alphaValue                = mode.passwordFieldAlpha

        simplenoteTitleView.isHidden = !mode.isIntroView
        simplenoteSubTitleView.isHidden = !mode.isIntroView

        headerLabel.isHidden = mode.header == nil
    }

    /// Animates Visible / Invisible components, based on the specified state
    ///
    func refreshVisibleComponentsWithAnimation() {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = AppKitConstants.duration0_2

            passwordFieldHeightConstraint.animator().constant   = mode.passwordFieldHeight

            passwordField.alphaValue            = mode.passwordFieldAlpha
            
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

    private func authViewController(with mode: AuthenticationMode, state: AuthenticationState) -> AuthViewController {
        let vc = AuthViewController()
        vc.authenticator = authenticator
        vc.state = state
        vc.mode = mode

        return vc
    }

    @objc
    func pushEmailLoginView() {
        containingNavigationController?.push(authViewController(with: .requestLoginCode, state: state))
    }

    @objc
    func pushSignupView() {
        containingNavigationController?.push(authViewController(with: .signup, state: state))
    }

    @objc
    func pushPasswordView() {
        containingNavigationController?.push(authViewController(with: .loginWithPassword(), state: state))
    }

    func pushCodeLoginView() {
        containingNavigationController?.push(authViewController(with: .loginWithCode, state: state))
    }
}


// MARK: - Handlers
//
extension AuthViewController {

    @IBAction
    func switchToPasswordAuth(_ sender: Any) {
        mode = AuthenticationMode.loginWithPassword(header: nil)
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
        Task {
            await performLoginWithEmailRequestInTask()
        }
    }
     
    @MainActor
    func performLoginWithEmailRequestInTask() async {
        defer {
            stopActionAnimation()
            setInterfaceEnabled(true)
        }
        
        startActionAnimation()
        setInterfaceEnabled(false)


        do {
            let email = usernameText
            let remote = LoginRemote()
            try await remote.requestLoginEmail(email: email)

            pushCodeLoginView()
        } catch {
            let statusCode = (error as? RemoteError)?.statusCode ?? .zero
            self.showAuthenticationError(forCode: statusCode, responseString: nil)
        }
    }

    @MainActor
    func loginWithCode(username: String, code: String) async throws {
        let remote = LoginRemote()

        do {
            let confirmation = try await remote.requestLoginConfirmation(email: username, authCode: code.uppercased())
            authenticator.authenticate(withUsername: confirmation.username, token: confirmation.syncToken)
        } catch {
            //TODO: Handle errors
        }
    }

    @objc
    func wordpressSSOAction() {
        let sessionsState = "app-\(UUID().uuidString)"
        UserDefaults.standard.set(sessionsState, forKey: .SPAuthSessionKey)

        let requestURL = String(format: SPWPSignInAuthURL, SPCredentials.wpcomClientID, SPCredentials.wpcomRedirectURL, sessionsState)
        let encodedURL = requestURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        NSWorkspace.shared.open(URL(string: encodedURL!)!)

        SPTracker.trackWPCCButtonPressed()
    }

    @objc
    func performLogInWithCode() {
        //TODO: Add login with code
    }

    @IBAction
    func handleNewlineInField(_ field: NSControl) {
        if field.isEqual(passwordField.textField) {
            guard let primaryActionDescriptor = mode.actions.first(where: { $0.name == .primary }) else {
                assertionFailure()
                return
            }

            performSelector(onMainThread: primaryActionDescriptor.selector, with: nil, waitUntilDone: false)
            return
        }
    }

    @objc
    func updateState(with object: Any) {
        guard let field = object as? NSTextField,
                let superView = field.superview else {
            return
        }

        switch superView {
        case usernameField:
            state.username = usernameField.stringValue
        case passwordField:
            state.password = passwordField.stringValue
        case codeTextField:
            state.code = passwordField.stringValue
        default:
            return
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
        //TODO: Fix animating title changes
//        actionButton.title = mode.primaryActionText
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
    
    //TODO: Drop this method?
    func presentMagicLinkRequestedView(email: String) {
        guard let authWindowController else {
            return
        }
        
        authWindowController.switchToMagicLinkRequestedUI(email: email)
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
    static let codePlaceholder = NSLocalizedString("Code", comment: "Placeholder text for code field")
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
