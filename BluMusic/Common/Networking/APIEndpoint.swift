//
//  APIEndpoint.swift
//  BluMusic
//
//  Created by Muhammad M. Munir on 18/05/24.
//

import Foundation

// MARK: - APIEndpoint
public class APIEndpoint<R>: ResponseRequestable {
    public typealias Response = R

    public let path: String
    public let useBaseURL: Bool
    public let method: HTTPMethod
    public let headers: [String: String]
    public let queryParametersEncodable: Encodable?
    public let queryParameters: [String: Any]
    public let bodyParametersEncodable: Encodable?
    public let bodyParameters: [String: Any]
    public let bodyEncoding: HTTPBodyEncoding
    public let responseDecoder: ResponseDecoderInterface

    init(path: String,
         useBaseURL: Bool = true,
         method: HTTPMethod,
         headers: [String: String] = [:],
         queryParametersEncodable: Encodable? = nil,
         queryParameters: [String: Any] = [:],
         bodyParametersEncodable: Encodable? = nil,
         bodyParameters: [String: Any] = [:],
         bodyEncoding: HTTPBodyEncoding = .json,
         responseDecoder: ResponseDecoderInterface = JSONResponseDecoder()
    ) {
        self.path = path
        self.useBaseURL = useBaseURL
        self.method = method
        self.headers = headers
        self.queryParametersEncodable = queryParametersEncodable
        self.queryParameters = queryParameters
        self.bodyParametersEncodable = bodyParametersEncodable
        self.bodyParameters = bodyParameters
        self.bodyEncoding = bodyEncoding
        self.responseDecoder = responseDecoder
    }
}

public protocol Requestable {
    var path: String { get }
    var useBaseURL: Bool { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var queryParametersEncodable: Encodable? { get }
    var queryParameters: [String: Any] { get }
    var bodyParametersEncodable: Encodable? { get }
    var bodyParameters: [String: Any] { get }
    var bodyEncoding: HTTPBodyEncoding { get }

    func urlRequest(with config: APIServiceConfigInterface) throws -> URLRequest
}

public protocol ResponseRequestable: Requestable {
    associatedtype Response

    var responseDecoder: ResponseDecoderInterface { get }
}

extension Requestable {

    func buildURL(using config: APIServiceConfigInterface) throws -> URL {
        var baseURL = config.baseURL
        if !config.baseURL.hasSuffix("/") {
            baseURL.append("/")
        }

        let endpoint = useBaseURL ? baseURL.appending(self.path) : self.path

        guard var urlComponents = URLComponents(string: endpoint)
        else { throw URLRequestError.invalidPath }

        var queryItems = [URLQueryItem]()

        // add default parameter from config
        config.queryParams.forEach {
            queryItems.append(URLQueryItem(name: $0.key, value: $0.value))
        }

        // add additional parameter
        let params = try self.queryParametersEncodable?.toDictionary() ?? self.queryParameters
        params.forEach {
            queryItems.append(URLQueryItem(name: $0.key, value: "\($0.value)"))
        }

        if !queryItems.isEmpty {
            urlComponents.queryItems = queryItems
        }

        guard let url = urlComponents.url
        else { throw URLRequestError.invalidURLComponents }

        return url
    }

    public func urlRequest(with config: APIServiceConfigInterface) throws -> URLRequest {
        let url = try self.buildURL(using: config)
        var urlRequest = URLRequest(url: url)
        var allHeaders: [String: String] = config.headers
        self.headers.forEach { allHeaders.updateValue($1, forKey: $0) }

        let bodyParams = try self.bodyParametersEncodable?.toDictionary() ?? self.bodyParameters
        if !bodyParams.isEmpty {
            urlRequest.httpBody = self.encodeBody(
                bodyParameters: bodyParams,
                bodyEncoding: self.bodyEncoding
            )
        }
        urlRequest.httpMethod = self.method.rawValue
        urlRequest.allHTTPHeaderFields = allHeaders

        return urlRequest
    }

    private func encodeBody(
        bodyParameters: [String: Any],
        bodyEncoding: HTTPBodyEncoding
    ) -> Data? {
        switch bodyEncoding {
        case .json:
            return try? JSONSerialization.data(withJSONObject: bodyParameters)
        case .queryString:
            return bodyParameters.queryString.data(
                using: String.Encoding.ascii,
                allowLossyConversion: true)
        }
    }
}

// MARK: - HTTPMethod
public enum HTTPMethod: String {
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
}

// MARK: - HTTPBodyEncoding
public enum HTTPBodyEncoding {
    case json
    case queryString
}

// MARK: - URLComponents error
enum URLRequestError: Error {
    case invalidPath
    case invalidURLComponents
}

// MARK: - Dictionary to Query Mapping
private extension Dictionary {
    var queryString: String {
        return self.map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) ?? ""
    }
}

// MARK: - Encodable to Dictionay Mapping
private extension Encodable {
    func toDictionary() throws -> [String: Any]? {
        let data = try JSONEncoder().encode(self)
        let jsonData = try JSONSerialization.jsonObject(with: data)
        return jsonData as? [String : Any]
    }
}
