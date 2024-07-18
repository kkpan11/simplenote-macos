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
        view = NSView()
        let initialView = initialViewController.view
        let spacerView = NSView(frame: NSRect(x: 0, y: 0, width: 100, height: 30))

        let buttonImage = NSImage(named: NSImage.goBackTemplateName)!
        let button = NSButton(title: String(), image: NSImage(named: NSImage.goBackTemplateName)!, target: nil, action: #selector(backWasPressed))
        button.bezelStyle = .accessoryBarAction

        view.translatesAutoresizingMaskIntoConstraints = false
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false

        backButton = button
        backButton.isHidden = hideBackButton

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

        show(initialView)
    }

    private func show(_ newView: NSView) {
        view.addSubview(newView)
        NSLayoutConstraint.activate([
            newView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            newView.topAnchor.constraint(equalTo: backButton.bottomAnchor),
            newView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func push(_ viewController: NSViewController) {

        currentView?.removeFromSuperview()

        let newView = viewController.view
        viewStack.append(viewController)
        addChild(viewController)

        show(newView)
        refreshView()
    }

    func popViewController() {
        guard viewStack.count > 1 else {
            return
        }

        let viewControllerToPop = viewStack.removeLast()
        viewControllerToPop.view.removeFromSuperview()
        viewControllerToPop.removeFromParent()

        show(currentView!)
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
