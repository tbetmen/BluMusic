//
//  MockAPIServiceErrorLogger.swift
//  BluMusicTests
//
//  Created by Muhammad M. Munir on 19/05/24.
//

import Foundation
@testable import BluMusic

final class MockAPIServiceErrorLogger: APIServiceErrorLoggerInterface {
    var loggedErrors: [Error] = []
    func log(request: URLRequest) {}
    func log(responseData data: Data?, response: URLResponse?) {}
    func log(error: Error) {
        self.loggedErrors.append(error)
    }
}
