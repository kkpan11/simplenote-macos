import Foundation

// MARK: - LoginRemote
//
class LoginRemote: Remote {

    func requestLoginEmail(email: String) async throws {
        let request = requestForLoginRequest(with: email)
        try await performDataTask(with: request)
    }

    func requestLoginConfirmation(authKey: String, authCode: String) async throws -> LoginConfirmationResponse {
        let request = requestForLoginCompletion(authKey: authKey, authCode: authCode)
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

    func requestForLoginRequest(with email: String) -> URLRequest {
        let url = URL(string: SimplenoteConstants.loginRequestURL)!
        return requestForURL(url, method: RemoteConstants.Method.POST, httpBody: [
            "request_source": SimplenoteConstants.simplenotePlatformName,
            "username": email.lowercased()
        ])
    }

    func requestForLoginCompletion(authKey: String, authCode: String) -> URLRequest {
        let url = URL(string: SimplenoteConstants.loginCompletionURL)!
        return requestForURL(url, method: RemoteConstants.Method.POST, httpBody: [
            "auth_key": authKey,
            "auth_code": authCode
        ])
    }
}
