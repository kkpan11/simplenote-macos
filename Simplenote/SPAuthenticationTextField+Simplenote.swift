import Simperium_OSX

extension SPAuthenticationTextField {
    @discardableResult
    override open func becomeFirstResponder() -> Bool {
        let responderStatus = textField.becomeFirstResponder()

        let selectedRange = textField.currentEditor()?.selectedRange
        textField.currentEditor()?.selectedRange = NSMakeRange(selectedRange?.length ?? .zero, .zero)

        return responderStatus
    }
}
