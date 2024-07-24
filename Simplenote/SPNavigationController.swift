import Foundation
import AppKit

class SPNavigationController: NSViewController {
    // MARK: - ViewController
    //
    private var viewStack: [NSViewController] = []
    private var backButton: NSButton!

    var hideBackButton: Bool {
        viewStack.count < 2
    }

    var topViewController: NSViewController? {
        viewStack.last
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
        guard let initialViewController = topViewController else {
            fatalError()
        }

        view = NSView()
        let initialView = initialViewController.view
        backButton = insertBackButton()

        view.translatesAutoresizingMaskIntoConstraints = false
        initialView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(initialView)

        NSLayoutConstraint.activate([
            initialView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            initialView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            initialView.topAnchor.constraint(equalTo: backButton.bottomAnchor),
            initialView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func insertBackButton() -> NSButton {
        let button = NSButton(title: String(), image: NSImage(named: NSImage.goBackTemplateName)!, target: nil, action: #selector(backWasPressed))

        button.translatesAutoresizingMaskIntoConstraints = false

        backButton = button
        backButton.isHidden = hideBackButton
        button.bezelStyle = .accessoryBarAction

        view.addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            backButton.widthAnchor.constraint(equalToConstant: 50),
            backButton.heightAnchor.constraint(equalToConstant: 30)
        ])

        return button
    }

    @objc
    func backWasPressed() {
        popViewController()
    }

    // MARK: - Add a View to the stack
    //
    func push(_ viewController: NSViewController, animated: Bool = true) {
        let currentView = topViewController?.view

        attach(child: viewController)
        if let currentView {
            currentView.removeConstraints(currentView.constraints)
        }

        guard let (leadingAnchor, trailingAnchor) = attachView(subview: viewController.view, below: currentView) else {
            return
        }

        guard animated else {
            return
        }

        leadingAnchor.constant = view.frame.width
        trailingAnchor.constant = view.frame.width

        animateTransition(slidingView: viewController.view, fadingView: currentView, direction: .trailingToLeading) {
            currentView?.removeFromSuperview()
        }
    }

    private func attach(child: NSViewController) {
        addChild(child)
        viewStack.append(child)
    }

    @discardableResult
    private func attachView(subview: NSView, below siblingView: NSView?) -> (leading: NSLayoutConstraint, trailing: NSLayoutConstraint)? {
        if let siblingView {
            view.addSubview(subview, positioned: .below, relativeTo: siblingView)
        } else {
            view.addSubview(subview)
        }

        subview.translatesAutoresizingMaskIntoConstraints = false

        let leadingAnchor = subview.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let trailingAnchor = subview.trailingAnchor.constraint(equalTo: view.trailingAnchor)

        NSLayoutConstraint.activate([
            leadingAnchor,
            trailingAnchor,
            subview.topAnchor.constraint(equalTo: backButton.bottomAnchor),
            subview.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])


        return (leading: leadingAnchor, trailing: trailingAnchor)
    }

    // MARK: - Remove view from stack
    func popViewController() {
        guard viewStack.count > 1 else {
            return
        }

        let currentViewController = viewStack.removeLast()
        guard let nextViewController = viewStack.last else {
            return
        }
  
        attachView(subview: nextViewController.view, below: currentViewController.view)
        
        animateTransition(slidingView: currentViewController.view, fadingView: nextViewController.view, direction: .leadingToTrailing) {
            self.dettach(child: currentViewController)
        }
    }

    private func dettach(child: NSViewController) {
        child.view.removeFromSuperview()
        child.removeFromParent()
    }

    // MARK: - Animation
    //
    private enum AnimationDirection {
        case leadingToTrailing
        case trailingToLeading
    }

    private func animateTransition(slidingView: NSView, fadingView: NSView?, direction: AnimationDirection, onCompletion: @escaping () -> Void) {
        guard let leadingConstraint = view.firstContraint(firstView: slidingView, firstAttribute: .leading),
              let trailingConstraint = view.firstContraint(firstView: slidingView, firstAttribute: .trailing) else {
            return
        }

        let multiplier: CGFloat = direction == .leadingToTrailing ? 1 : -1
        let alpha: CGFloat = direction == .leadingToTrailing ? 1 : 0

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.4
            context.timingFunction = .init(name: .easeInEaseOut)

            fadingView?.animator().alphaValue = alpha
            leadingConstraint.animator().constant += view.frame.width * multiplier
            trailingConstraint.animator().constant += view.frame.width * multiplier
            backButton.animator().isHidden = hideBackButton
        } completionHandler: {
            onCompletion()
        }
    }
}
