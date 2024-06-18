import Foundation


// MARK: - SimperiumAuthenticatorProtocol
//
protocol SimperiumAuthenticatorProtocol {
    func authenticate(withUsername username: String, token: String)
}


extension SPAuthenticator: SimperiumAuthenticatorProtocol { }
