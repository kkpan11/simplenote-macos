import Foundation
@testable import Simplenote


// MARK: - MockLoginRemote
//
class MockLoginRemote: LoginRemoteProtocol {
    var lastLoginRequestEmail: String?
    
    var onLoginConfirmationRequest: ((_ email: String, _ authCode: String) -> LoginConfirmationResponse)?
    
    func requestLoginEmail(email: String) async throws {
        lastLoginRequestEmail = email
    }
    
    func requestLoginConfirmation(email: String, authCode: String) async throws -> LoginConfirmationResponse {
        guard let response = onLoginConfirmationRequest?(email, authCode) else {
            throw RemoteError.network
        }

        return response
    }
}
