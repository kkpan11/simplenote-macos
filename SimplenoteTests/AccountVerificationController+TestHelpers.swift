import Foundation
import SimplenoteEndpoints
@testable import Simplenote


extension AccountVerificationController {
    func randomResult() -> Result<Data?, RemoteError> {
        if Bool.random() {
            return .success(nil)
        }
        
        let error = RemoteError(statusCode: .zero, response: nil, networkError: nil)
        return .failure(error)
    }
}
