import Foundation
@testable import Simplenote


// MARK: - MockSimperiumAuthenticator
//
class MockSimperiumAuthenticator: SimperiumAuthenticatorProtocol {
    
    var onAuthenticationRequest: ((_ username: String, _ token: String) -> Void)?
    
    func authenticate(withUsername username: String, token: String) {
        onAuthenticationRequest?(username, token)
    }
}
