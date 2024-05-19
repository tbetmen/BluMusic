//
//  MockAPIServiceConfig.swift
//  BluMusicTests
//
//  Created by Muhammad M. Munir on 19/05/24.
//

@testable import BluMusic

final class MockAPIServiceConfig: APIServiceConfigInterface {
    var baseURL: String = "https://api.test.com"
    var headers: [String : String] = [:]
    var queryParams: [String : String] = [:]
}
