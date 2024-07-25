import Foundation


// MARK: - AuthenticationError
//
public enum AuthenticationError: Error {
    case compromisedPassword
    case invalidCode
    case loginBadCredentials
    case network
    case requestNotFound
    case tooManyAttempts
    case unverifiedEmail
    case unknown(statusCode: Int, response: String?, error: Error?)
}


// MARK: - Initializers
//
extension AuthenticationError {

    /// Returns the AuthenticationError for a given Login statusCode + Response
    ///
    public init(statusCode: Int, response: String?, error: Error?) {
        switch statusCode {
        case .zero:
            self = .network
        case 400 where response == ErrorResponse.requestNotFound:
            self = .requestNotFound
        case 400 where response == ErrorResponse.invalidCode:
            self = .invalidCode
        case 401 where response == ErrorResponse.compromisedPassword:
            self = .compromisedPassword
        case 401:
            self = .loginBadCredentials
        case 403 where response == ErrorResponse.requiresVerification:
            self = .unverifiedEmail
        case 429:
            self = .tooManyAttempts
        default:
            self = .unknown(statusCode: statusCode, response: response, error: error)
        }
    }
}


// MARK: - Error Responses
//
private struct ErrorResponse {
    static let compromisedPassword = "compromised password"
    static let requiresVerification = "verification required"
    static let requestNotFound = "request-not-found"
    static let invalidCode = "invalid-code"
}
