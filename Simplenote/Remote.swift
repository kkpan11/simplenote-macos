import Foundation

class Remote {
    private let urlSession: URLSession

    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }

    /// Send  task for remote
    /// Sublcassing Notes: To be able to send a task it is required to first setup the URL request for the task to use
    ///
    func performDataTask(with request: URLRequest, completion: @escaping (_ result: Result<Data?, RemoteError>) -> Void) {
        let dataTask = urlSession.dataTask(with: request) { (data, response, dataTaskError) in
            DispatchQueue.main.async {
                
                if let response, let error = RemoteError(statusCode: response.responseStatusCode, error: dataTaskError) {
                    completion(.failure(error))
                    return
                }

                completion(.success(data))
            }
        }

        dataTask.resume()
    }
}
