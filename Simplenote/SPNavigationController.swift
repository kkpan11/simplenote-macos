import Foundation

class SPNavigationController: NSViewController {
    private var viewStack: [NSViewController] = []

    private var backButton: NSButton!

    var initialViewController: NSViewController {
        guard let first = viewStack.first else {
            fatalError()
        }

        return first
    }

    var currentView: NSView? {
        viewStack.last?.view
    }

    var hideBackButton: Bool {
        viewStack.count < 2
    }

    init(initialViewController: NSViewController) {
        super.init(nibName: nil, bundle: nil)
        viewStack.append(initialViewController)
        addChild(initialViewController)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let initialView = initialViewController.view
        let spacerView = NSView(frame: NSRect(x: 0, y: 0, width: 100, height: 30))
        let button = NSButton(title: String(), image: NSImage(named: NSImage.goBackTemplateName)!, target: nil, action: #selector(backWasPressed))
        view = NSView()

        view.frame = NSRect(x: 0, y: 0, width: initialView.frame.width, height: 500)

        view.translatesAutoresizingMaskIntoConstraints = false
        initialView.translatesAutoresizingMaskIntoConstraints = false
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false

        backButton = button
        backButton.isHidden = hideBackButton
        button.bezelStyle = .accessoryBarAction

        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(lessThanOrEqualToConstant: 380)
        ])

        view.addSubview(spacerView)
        NSLayoutConstraint.activate([
            spacerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            spacerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            spacerView.heightAnchor.constraint(equalToConstant: 30),
            spacerView.topAnchor.constraint(equalTo: view.topAnchor)
        ])

        view.addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            backButton.topAnchor.constraint(equalTo: spacerView.bottomAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 50)
        ])

        view.addSubview(initialView)

        NSLayoutConstraint.activate([
            initialView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            initialView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            initialView.topAnchor.constraint(equalTo: backButton.bottomAnchor),
            initialView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func push(_ viewController: NSViewController, animated: Bool = true) {

        guard let currentView else {
            return
        }
        currentView.removeFromSuperview()

        guard let leadingAnchor = attach(child: viewController) else {
            return
        }

        guard animated else {
            return
        }

        leadingAnchor.constant = view.frame.width

        viewStack.append(viewController)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.75

            leadingAnchor.animator().constant = 0
            refreshView()
        }
    }

    private func attach(child: NSViewController) -> NSLayoutConstraint? {
        let subview = child.view

        addChild(child)
        view.addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false

        let leadingAnchor = subview.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        NSLayoutConstraint.activate([
            leadingAnchor,
            subview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            subview.topAnchor.constraint(equalTo: backButton.bottomAnchor),
            subview.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        return leadingAnchor
    }

    func popViewController() {
        guard viewStack.count > 1 else {
            return
        }

        let viewControllerToPop = viewStack.removeLast()
        viewControllerToPop.view.removeFromSuperview()
        viewControllerToPop.removeFromParent()

        refreshView()
    }

    @objc
    func backWasPressed() {
        popViewController()
    }

    private func refreshView() {
        backButton.isHidden = hideBackButton
        view.window?.layoutIfNeeded()
    }
}
