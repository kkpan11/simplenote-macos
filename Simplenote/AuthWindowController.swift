import Foundation
import AppKit
import SwiftUI


// MARK: - AuthWindowController
//
class AuthWindowController: NSWindowController, SPAuthenticationInterface {

    /// Starting Point!
    ///
    let authViewController: AuthViewController

    /// Simperium's Authenticator Instance
    ///
    var authenticator: SPAuthenticator? {
        didSet {
            authViewController.authenticator = authenticator
        }
    }

    // MARK: - Initializer
    
    deinit {
        stopListeningToNotifications()
    }

    init() {
        self.authViewController = AuthViewController(mode: .onboarding, state: AuthenticationState())
        let navigationController = SPNavigationController(initialViewController: authViewController)
        let window = NSWindow(contentViewController: navigationController)
        window.styleMask = [.borderless, .closable, .titled, .fullSizeContentView]
        window.appearance = NSAppearance(named: .aqua)
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isOpaque = false
        window.backgroundColor = .white

        super.init(window: window)
        startListeningToNotifications()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - Notifications
//
extension AuthWindowController {
    
    func startListeningToNotifications() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(displayAuthenticationInProgress), name: .magicLinkAuthWillStart, object: nil)
    }
    
    func stopListeningToNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc
    func displayAuthenticationInProgress(_ sender: Notification) {
        DispatchQueue.main.async {
            self.switchToMagicLinkConfirmationUI()
        }
    }
}


// MARK: - User Interface
//
extension AuthWindowController {

    func switchToAuthenticationUI() {
        guard let window else {
            return
        }
        
        let authViewController = AuthViewController()
        authViewController.authenticator = authenticator
        window.transition(to: authViewController)
    }
    
    func switchToMagicLinkRequestedUI(email: String) {
        guard let window else {
            return
        }

        /// Renders a UI that indicates a Magic Link has been requested
        ///
        var rootView = MagicLinkRequestedView(email: email)
        rootView.onDismissRequest = { [weak self] in
            self?.switchToAuthenticationUI()
        }
        
        let hostingController = NSHostingController(rootView: rootView)
        window.switchContentViewController(to: hostingController)
    }

    func switchToMagicLinkConfirmationUI() {
        guard let window else {
            return
        }

        /// Renders a spinner while we attempt to authorize a Magic Link.
        /// It'll pick up the `magicLinkAuthDidFail` Notification, and will display an error, if needed.
        ///
        var rootView = MagicLinkConfirmationView()
        rootView.onDismissRequest = { [weak self] in
            self?.switchToAuthenticationUI()
        }
        
        let hostingController = NSHostingController(rootView: rootView)
        window.switchContentViewController(to: hostingController)
    }
}
