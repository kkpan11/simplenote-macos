import Foundation

// MARK: - NSWindow / Transitons
//
extension NSWindow {

    /// Performs a FadeIn Transition to the specified ViewController
    ///
    func transition(to viewController: NSViewController) {
        let targetView = viewController.view
        targetView.alphaValue = AppKitConstants.alpha0_0

        // Force Layout immediately: Prevent unexpected animations while fading in
        targetView.needsLayout = true
        targetView.layoutSubtreeIfNeeded()

        NSAnimationContext.runAnimationGroup { context in
            context.allowsImplicitAnimation = true
            context.duration = AppKitConstants.duration0_4
            targetView.alphaValue = AppKitConstants.alpha1_0

            self.contentViewController = viewController
            self.layoutIfNeeded()
        }
    }
    
    /// Switches to the target ContentViewController, without animations
    ///
    func switchContentViewController(to viewController: NSViewController) {
        let targetView = viewController.view
        targetView.layoutSubtreeIfNeeded()
        
        let newSize = targetView.intrinsicContentSize
        
        var frame = frame
        frame.origin.y += frame.size.height - newSize.height
        frame.size = newSize

        contentViewController = viewController
        setFrame(frame, display: true)
    }
}
