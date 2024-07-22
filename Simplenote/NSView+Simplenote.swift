import Foundation

// MARK: - NSView + Simplenote
//
extension NSView {

    /// Indicates if either the Receiver is the First responder (OR) the receiver is the Field Editor's delegate
    ///
    var isFirstResponder: Bool {
        guard let responder = window?.firstResponder else {
            return false
        }

        if responder == self {
            return true
        }

        let fieldEditor = responder as? NSText
        let effectiveResponder = fieldEditor?.delegate as? NSControl
        return effectiveResponder == self
    }

    /// Returns first layout constraint found for attribute type
    ///
    func firstContraint(firstView: NSView, firstAttribute: NSLayoutConstraint.Attribute) -> NSLayoutConstraint? {
        constraints.first(where: { $0.firstItem as? NSView == firstView && $0.firstAttribute == firstAttribute })
    }
}
