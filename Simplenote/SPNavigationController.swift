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

//        let viewController = NSViewController()
//        let view = NSView(frame: NSRect(x: 0, y: 0, width: 300, height: 300))
//        viewController.view = view
//        view.wantsLayer = true
//        view.layer?.backgroundColor = NSColor.green.cgColor
//
//        let button = NSButton(frame: NSRect(x: 20, y: 20, width: 20, height: 20))
//        button.action = #selector(animateNewView)
//
//        view.addSubview(button)
//        addChild(viewController)
//        viewStack.append(viewController)
        viewStack.append(initialViewController)
        addChild(initialViewController)
    }

    @objc
    func animateNewView() {
        let newView = NSView(frame: NSRect(x: 300, y: 0, width: 300, height: 300))
        newView.wantsLayer = true
        newView.layer?.backgroundColor = NSColor.red.cgColor

        view.addSubview(newView)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.5
            currentView?.animator().frame.origin.x -= 300
            newView.animator().frame.origin.x -= 300
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let initialView = initialViewController.view
        let spacerView = NSView(frame: NSRect(x: 0, y: 0, width: 100, height: 30))
        let button = NSButton(title: String(), image: NSImage(named: NSImage.goBackTemplateName)!, target: nil, action: #selector(backWasPressed))
        view = NSView()

        view.frame = NSRect(x: 0, y: 0, width: initialView.frame.width, height: initialView.frame.height)

        view.translatesAutoresizingMaskIntoConstraints = false
        initialView.translatesAutoresizingMaskIntoConstraints = false
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false

        backButton = button
        backButton.isHidden = hideBackButton
        button.bezelStyle = .accessoryBarAction

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
    }

    private func show(_ newView: NSView) {
        view.addSubview(newView)
//        NSLayoutConstraint.activate([
//            newView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            newView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            newView.topAnchor.constraint(equalTo: backButton.bottomAnchor),
//            newView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
    }

    func push(_ viewController: NSViewController) {

//        currentView?.removeFromSuperview()
//
//        let newView = viewController.view
//        viewStack.append(viewController)
//        addChild(viewController)
//
//        show(newView)
//        refreshView()

        guard let currentView else {
            return
        }

        currentView.removeConstraints(currentView.constraints)

        addChild(viewController)
        let newView = viewController.view

        newView.frame.origin.x += currentView.frame.width
        view.addSubview(newView)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.75

            currentView.animator().frame.origin.x -= currentView.frame.width
            newView.animator().frame.origin.x -= currentView.frame.width
        }
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
