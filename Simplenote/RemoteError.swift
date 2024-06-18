import Foundation

enum RemoteError: Error {
    case network
    case requestError(Int, Error?)
}

extension RemoteError {
    
    init?(statusCode: Int, error: Error? = nil) {
        if statusCode / 100 == 2 {
            return nil
        }

        self = statusCode > 0 ? .requestError(statusCode, error) : .network
    }
}


extension RemoteError {
    var statusCode: Int {
        switch self {
        case .requestError(let statusCode, _):
            return statusCode
        default:
            return .zero
        }
    }
}

extension RemoteError: Equatable {
    static func == (lhs: RemoteError, rhs: RemoteError) -> Bool {
        switch (lhs, rhs) {
        case (.network, .network):
            return true
        case (.requestError(let lhsStatus, let lhsError), .requestError(let rhsStatus, let rhsError)):
            return lhsStatus == rhsStatus && lhsError?.localizedDescription == rhsError?.localizedDescription
        default:
            return false
        }
    }
}
