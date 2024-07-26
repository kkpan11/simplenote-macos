import Foundation


// MARK: - Alert + AuthError
//
extension NSAlert {
    
    static func buildLoginCodeExpiredAlert() -> NSAlert {
        let titleText = NSLocalizedString("Sorry!", comment: "LoginCode Expired Title")
        let messageText = NSLocalizedString("The authentication code you've requested has expired. Please request a new one", comment: "LoginCode Expired Message")
        let acceptText = NSLocalizedString("Accept", comment: "Accept Message")
        
        let alert = NSAlert()
        alert.messageText = titleText
        alert.informativeText = messageText
        alert.addButton(withTitle: acceptText)

        return alert
    }
}
