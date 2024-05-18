//
//  DataTransfer.swift
//  BluMusic
//
//  Created by Muhammad M. Munir on 18/05/24.
//

import Foundation

// MARK: - DataTransferError
public enum DataTransferError: Error {
    case noResponse
    case parsing(Error)
    case networkFailure(APIServiceError)
    case resolvedNetworkFailure(Error)
}

// MARK: - DataTransferServiceInterface
public protocol DataTransferServiceInterface {
    typealias CompletionHandler<T> = (Result<T, DataTransferError>) -> Void

    @discardableResult
    func request<T: Decodable, E: ResponseRequestable>(
        with endpoint: E,
        completion: @escaping CompletionHandler<T>
    ) -> APIServiceCancellableInterface? where E.Response == T

    @discardableResult
    func request<E: ResponseRequestable>(
        with endpoint: E,
        completion: @escaping CompletionHandler<Void>
    ) -> APIServiceCancellableInterface? where E.Response == Void
}

public class DataTransferService {
    private let apiService: APIServiceInterface
    private let errorResolver: DataTransferErrorResolverInterface

    public init(
        apiService: APIServiceInterface = APIService(),
        errorResolver: DataTransferErrorResolverInterface = DataTransferErrorResolver()
    ) {
        self.apiService = apiService
        self.errorResolver = errorResolver
    }
}

extension DataTransferService: DataTransferServiceInterface {
    public func request<T, E>(
        with endpoint: E,
        completion: @escaping CompletionHandler<T>
    ) -> APIServiceCancellableInterface? where T : Decodable, T == E.Response, E : ResponseRequestable {

        return self.apiService.request(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                let result: Result<T, DataTransferError> = self.decode(
                    data: data, decoder: endpoint.responseDecoder
                )
                DispatchQueue.main.async {
                    return completion(result)
                }
            case .failure(let error):
                let error = self.resolve(networkError: error)
                DispatchQueue.main.async {
                    return completion(.failure(error))
                }
            }
        }
    }

    public func request<E>(
        with endpoint: E,
        completion: @escaping CompletionHandler<Void>
    ) -> APIServiceCancellableInterface? where E : ResponseRequestable, E.Response == Void {
        return self.apiService.request(endpoint: endpoint) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    return completion(.success(()))
                }
            case .failure(let error):
                let error = self.resolve(networkError: error)
                DispatchQueue.main.async {
                    return completion(.failure(error))
                }
            }
        }
    }

    private func decode<T: Decodable>(
        data: Data?,
        decoder: ResponseDecoderInterface
    ) -> Result<T, DataTransferError> {
        do {
            guard let data = data else { return .failure(.noResponse) }
            let result: T = try decoder.decode(data)
            return .success(result)
        } catch {
            return .failure(.parsing(error))
        }
    }

    private func resolve(
        networkError error: APIServiceError
    ) -> DataTransferError {
        let resolvedError = self.errorResolver.resolve(error: error)
        return resolvedError is APIServiceError ?
            .networkFailure(error) : .resolvedNetworkFailure(resolvedError)
    }
}

// MARK: - Error Resolver
public protocol DataTransferErrorResolverInterface {
    func resolve(error: APIServiceError) -> Error
}

public class DataTransferErrorResolver: DataTransferErrorResolverInterface {
    public init() {}
    public func resolve(error: APIServiceError) -> Error {
        return error
    }
}

// MARK: - ResponseDecoder
public protocol ResponseDecoderInterface {
    func decode<T: Decodable>(_ data: Data) throws -> T
}

public class JSONResponseDecoder: ResponseDecoderInterface {
    private let jsonDecoder: JSONDecoder

    public init(jsonDecoder: JSONDecoder = .init()) {
        self.jsonDecoder = jsonDecoder
    }

    public func decode<T>(_ data: Data) throws -> T where T : Decodable {
        return try self.jsonDecoder.decode(T.self, from: data)
    }
}

public class DataResponseDecoder: ResponseDecoderInterface {
    enum CodingKeys: String, CodingKey {
        case `default` = ""
    }

    public init() {}

    public func decode<T>(_ data: Data) throws -> T where T : Decodable {
        if T.self is Data.Type, let data = data as? T {
            return data
        } else {
            let context = DecodingError.Context(
                codingPath: [CodingKeys.default],
                debugDescription: "Expected Data type"
            )
            throw Swift.DecodingError.typeMismatch(T.self, context)
        }
    }
}
