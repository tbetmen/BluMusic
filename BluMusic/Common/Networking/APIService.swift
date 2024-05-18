//
//  APIService.swift
//  BluMusic
//
//  Created by Muhammad M. Munir on 18/05/24.
//

import Foundation

// MARK: - APIServiceError
public enum APIServiceError: Error {
    case error(statusCode: Int, data: Data?)
    case notConnected
    case cancelled
    case generic(Error)
    case urlGeneration
}

extension APIServiceError {
    public var isNotFoundError: Bool {
        return self.hasStatusCode(404)
    }

    public func hasStatusCode(_ codeError: Int) -> Bool {
        switch self {
        case let .error(code, _):
            return code == codeError
        default: return false
        }
    }
}

// MARK: - APIServiceCancellable
public protocol APIServiceCancellableInterface {
    func cancel()
}

extension URLSessionDataTask: APIServiceCancellableInterface {}

// MARK: - APIService
public protocol APIServiceInterface {
    typealias CompletionHandler = (Result<Data?, APIServiceError>) -> Void

    func request(
        endpoint: Requestable,
        completion: @escaping CompletionHandler
    ) -> APIServiceCancellableInterface?
}

public class APIService {

    private let config: APIServiceConfigInterface
    private let sessionManager: APISessionManagerInterface
    private let logger: APIServiceErrorLoggerInterface

    public init(
        config: APIServiceConfigInterface = APIServiceConfig.create(),
        sessionManager: APISessionManagerInterface = APISessionManager(),
        logger: APIServiceErrorLoggerInterface = APIServiceErrorLogger()
    ) {
        self.sessionManager = sessionManager
        self.config = config
        self.logger = logger
    }

    private func request(
        request: URLRequest,
        completion: @escaping CompletionHandler
    ) -> APIServiceCancellableInterface {

        let sessionDataTask = self.sessionManager.request(
            request
        ) { data, response, requestError in

            if let requestError = requestError {
                var error: APIServiceError
                if let response = response as? HTTPURLResponse {
                    error = .error(statusCode: response.statusCode, data: data)
                } else {
                    error = self.resolve(error: requestError)
                }

                self.logger.log(error: error)
                completion(.failure(error))
            } else {
                self.logger.log(responseData: data, response: response)
                completion(.success(data))
            }
        }

        self.logger.log(request: request)
        return sessionDataTask
    }

    private func resolve(error: Error) -> APIServiceError {
        let code = URLError.Code(rawValue: (error as NSError).code)
        switch code {
        case .notConnectedToInternet: return .notConnected
        case .cancelled: return .cancelled
        default: return .generic(error)
        }
    }
}

extension APIService: APIServiceInterface {

    public func request(
        endpoint: Requestable,
        completion: @escaping CompletionHandler
    ) -> APIServiceCancellableInterface? {
        do {
            let urlRequest = try endpoint.urlRequest(with: config)
            return self.request(request: urlRequest, completion: completion)
        } catch {
            completion(.failure(.urlGeneration))
            return nil
        }
    }
}

// MARK: - APISessionManager
public protocol APISessionManagerInterface {
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void

    func request(
        _ request: URLRequest,
        completion: @escaping CompletionHandler
    ) -> APIServiceCancellableInterface
}

public class APISessionManager: APISessionManagerInterface {

    private let urlSession: URLSession

    public init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    public func request(
        _ request: URLRequest,
        completion: @escaping CompletionHandler
    ) -> APIServiceCancellableInterface {
        let task = self.urlSession.dataTask(with: request, completionHandler: completion)
        task.resume()
        return task
    }
}

// MARK: - Logger
public protocol APIServiceErrorLoggerInterface {
    func log(request: URLRequest)
    func log(responseData data: Data?, response: URLResponse?)
    func log(error: Error)
}

public class APIServiceErrorLogger: APIServiceErrorLoggerInterface {
    public init() {}

    public func log(request: URLRequest) {
        print("-------------------------------------")
        print("request: \(request.url!)")
        print("headers: \(request.allHTTPHeaderFields!)")
        print("method: \(request.httpMethod!)")

        if let httpBody = request.httpBody,
           let result = ((try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [String: AnyObject]) as [String: AnyObject]??) {
            print("body: \(String(describing: result))")
        } else if let httpBody = request.httpBody,
                  let resultString = String(data: httpBody, encoding: .utf8) {
            print("body: \(String(describing: resultString))")
        }
    }

    public func log(responseData data: Data?, response: URLResponse?) {
        guard let data = data else { return }
        if let dataDict = try? JSONSerialization
            .jsonObject(with: data, options: []) as? [String: Any] {
            print("responseData: \(String(describing: dataDict))")
        }
    }

    public func log(error: Error) {
        print("\(error)")
    }
}
