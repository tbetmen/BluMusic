//
//  MockAPISessionManager.swift
//  BluMusicTests
//
//  Created by Muhammad M. Munir on 19/05/24.
//

import Foundation
@testable import BluMusic

struct MockAPISessionManager: APISessionManagerInterface {
    let response: HTTPURLResponse?
    let data: Data?
    let error: Error?

    func request(
        _ request: URLRequest,
        completion: @escaping CompletionHandler
    ) -> APIServiceCancellableInterface {
        completion(data, response, error)
        return URLSession.shared.dataTask(with: URL(string: "https://api.test.com")!)
    }
}
