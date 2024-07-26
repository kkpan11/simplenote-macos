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
    
    private var heightConstraint: NSLayoutConstraint? = nil

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
        heightConstraint = view.heightAnchor.constraint(equalToConstant: .zero)
        heightConstraint?.isActive = true
        let initialView = initialViewController.view
        backButton = insertBackButton()

        view.translatesAutoresizingMaskIntoConstraints = false
        initialView.translatesAutoresizingMaskIntoConstraints = false

        attachView(subview: initialViewController.view, below: nil, animated: false)

        /// "Hint" we wanna occupy as little as possible. This constraint is meant to be broken, but the layout system will
        /// attempt to reduce the Height, when possible
        ///
        let minimumHeightConstraint = view.heightAnchor.constraint(equalToConstant: .zero)
        minimumHeightConstraint.priority = .init(1)

        NSLayoutConstraint.activate([
            initialView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            initialView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            initialView.topAnchor.constraint(equalTo: backButton.bottomAnchor),
            initialView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            minimumHeightConstraint
        ])
    }

    private func insertBackButton() -> NSButton {
        let button = NSButton(title: String(), image: NSImage(named: NSImage.goBackTemplateName)!, target: nil, action: #selector(backWasPressed))

        button.translatesAutoresizingMaskIntoConstraints = false

        backButton = button
        backButton.isHidden = hideBackButton
        button.bezelStyle = .accessoryBarAction
        button.cell?.isBordered = false
        button.contentTintColor = .darkGray
        button.wantsLayer = true
        button.layer?.cornerRadius = 5
        let trackingArea = NSTrackingArea(rect: backButton.bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self)
        button.addTrackingArea(trackingArea)

        view.addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.buttonViewLeadingPadding),
            backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.buttonViewTopPadding),
            backButton.widthAnchor.constraint(equalToConstant: Constants.buttonViewWidth),
            backButton.heightAnchor.constraint(equalToConstant: Constants.buttonViewHeight)
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
        attachView(subview: viewController.view, below: currentView, animated: animated)

        guard animated else {
            currentView?.removeFromSuperview()
            backButton.isHidden = hideBackButton
            return
        }

        animateTransition(slidingView: viewController.view, fadingView: currentView, direction: .trailingToLeading) {
            currentView?.removeFromSuperview()
        }
    }

    private func attach(child: NSViewController) {
        addChild(child)
        viewStack.append(child)
    }

    private func attachView(subview: NSView, below siblingView: NSView?, animated: Bool) {

        let padding = Constants.buttonViewLeadingPadding + Constants.buttonViewHeight
        let finalHeight = subview.fittingSize.height + padding

        if let siblingView,
           animated {
            heightConstraint?.constant = siblingView.fittingSize.height + padding
            view.addSubview(subview, positioned: .below, relativeTo: siblingView)
        } else {
            view.addSubview(subview)
        }

        subview.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            subview.topAnchor.constraint(equalTo: backButton.bottomAnchor)
        ])

        guard animated else {
            heightConstraint?.constant = finalHeight
            return
        }

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.4
            context.timingFunction = .init(name: .easeInEaseOut)

            heightConstraint?.animator().constant = finalHeight
        }

        return
    }

    // MARK: - Remove view from stack
    func popViewController(animated: Bool = true) {
        guard viewStack.count > 1, let currentViewController = viewStack.popLast(), let nextViewController = viewStack.last else {
            return
        }
  
        attachView(subview: nextViewController.view, below: currentViewController.view, animated: animated)

        guard animated else {
            self.dettach(child: currentViewController)
            backButton.isHidden = hideBackButton
            return
        }

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

        if direction == .trailingToLeading {
            leadingConstraint.constant = view.frame.width
            trailingConstraint.constant = view.frame.width
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

// MARK: - Button Hover Color Animation
//
extension SPNavigationController {
    override func mouseEntered(with event: NSEvent) {
        backButton.layer?.backgroundColor = NSColor.lightGray.withAlphaComponent(0.1).cgColor
    }

    override func mouseExited(with event: NSEvent) {
        backButton.layer?.backgroundColor = .clear
    }
}

private struct Constants {
    static let buttonViewWidth = CGFloat(50)
    static let buttonViewHeight = CGFloat(30)
    static let buttonViewTopPadding = CGFloat(30)
    static let buttonViewLeadingPadding = CGFloat(10)
}
