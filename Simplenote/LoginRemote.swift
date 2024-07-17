import Foundation

// MARK: - LoginRemote
//
class LoginRemote: Remote {

    func requestLoginEmail(email: String) async throws {
        let request = requestForLoginRequest(email: email)
        try await performDataTask(with: request)
    }

    func requestLoginConfirmation(email: String, authCode: String) async throws -> LoginConfirmationResponse {
        let request = requestForLoginCompletion(email: email, authCode: authCode)
        return try await performDataTask(with: request, type: LoginConfirmationResponse.self)
    }
}


// MARK: - LoginConfirmationResponse
//
struct LoginConfirmationResponse: Codable, Equatable {
    let username: String
    let syncToken: String
}


// MARK: - Private API(s)
//
private extension LoginRemote {

    func requestForLoginRequest(email: String) -> URLRequest {
        let url = URL(string: SimplenoteConstants.loginRequestURL)!
        return requestForURL(url, method: RemoteConstants.Method.POST, httpBody: [
            "request_source": SimplenoteConstants.simplenotePlatformName,
            "username": email.lowercased()
        ])
    }

    func requestForLoginCompletion(email: String, authCode: String) -> URLRequest {
        let url = URL(string: SimplenoteConstants.loginCompletionURL)!
        return requestForURL(url, method: RemoteConstants.Method.POST, httpBody: [
            "username": email,
            "auth_code": authCode
        ])
    }
}
