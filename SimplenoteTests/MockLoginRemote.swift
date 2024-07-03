import Foundation
@testable import Simplenote


// MARK: - MockLoginRemote
//
class MockLoginRemote: LoginRemoteProtocol {
    var lastLoginRequestEmail: String?
    
    var onLoginConfirmationRequest: ((_ authKey: String, _ authCode: String) -> LoginConfirmationResponse)?
    
    func requestLoginEmail(email: String) async throws {
        lastLoginRequestEmail = email
    }
    
    func requestLoginConfirmation(authKey: String, authCode: String) async throws -> LoginConfirmationResponse {
        guard let response = onLoginConfirmationRequest?(authKey, authCode) else {
            throw RemoteError.network
        }

        return response
    }
}
