import Foundation
import SimplenoteEndpoints
import Simperium_OSX


// MARK: - SimperiumAuthenticatorProtocol
//
protocol SimperiumAuthenticatorProtocol {
    func authenticate(withUsername username: String, token: String)
}


extension SPAuthenticator: SimperiumAuthenticatorProtocol { }


extension SPUser: UserProtocol { }
