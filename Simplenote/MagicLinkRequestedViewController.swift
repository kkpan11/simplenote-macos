import Foundation
import AppKit


// MARK: - MagicLinkRequestedViewController
//
class MagicLinkRequestedViewController: NSViewController {

    /// Outlets
    ///
    @IBOutlet private var headingImageView: NSImageView!
    @IBOutlet private var messageTextField: NSTextField!
    @IBOutlet private var backButton: NSButton!

    /// Signup Email
    ///
    private let email: String

    /// Simperium's Authenticator: Required only in case we must present back the Authentication Flow
    ///
    private let authenticator: SPAuthenticator

    
    /// Designated Initializer
    ///
    init(email: String, authenticator: SPAuthenticator) {
        self.email = email
        self.authenticator = authenticator
        let nibName = type(of: self).classNameWithoutNamespaces
        super.init(nibName: nibName, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overridden Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        setupHeadingImage()
        setupMessageLabel()
        setupBackButton()
    }
}

// MARK: - Interface
//
private extension MagicLinkRequestedViewController {

    func setupHeadingImage() {
        headingImageView.contentTintColor = NSColor(studioColor: .spBlue50, alpha: AppKitConstants.alpha1_0)
    }

    func setupMessageLabel() {
        let text = String(format: Localization.messageTemplate, email)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor(studioColor: .gray90),
            .font: Fonts.regularMessageFont,
            .paragraphStyle: paragraphStyle
        ]

        let highlightAttributes: [NSAttributedString.Key: Any] = [
            .font: Fonts.boldMessageFont
        ]

        messageTextField.attributedStringValue = NSMutableAttributedString(string: text,
                                                                           attributes: attributes,
                                                                           highlighting: email,
                                                                           highlightAttributes: highlightAttributes)
    }

    func setupBackButton() {
        backButton.title = Localization.back
        backButton.contentTintColor = NSColor(studioColor: .spBlue50)
    }
}

// MARK: - Action Handlers
//
extension MagicLinkRequestedViewController {

    @IBAction
    func backWasPressed(_ sender: Any) {
        presentAuthenticationInteface()
    }

    private func presentAuthenticationInteface() {
        let authViewController = AuthViewController()
        authViewController.authenticator = authenticator
        view.window?.transition(to: authViewController)
    }
}

// MARK: - Localization
//
private enum Localization {
    static let messageTemplate = NSLocalizedString("If an account exists, we've sent an email to %1$@ containing a link that'll log you in.", comment: "Magic Link Confirmation UI")
    static let back = NSLocalizedString("Go Back", comment: "Back Button Title")
}

private enum Fonts {
    static let regularMessageFont = NSFont.systemFont(ofSize: 13)
    static let boldMessageFont = NSFont.boldSystemFont(ofSize: 13)
}
