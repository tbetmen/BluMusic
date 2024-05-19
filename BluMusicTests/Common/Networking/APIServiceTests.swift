//
//  APIServiceTests.swift
//  BluMusicTests
//
//  Created by Muhammad M. Munir on 19/05/24.
//

import XCTest
@testable import BluMusic

final class APIServiceTests: XCTestCase {

    enum APIServiceErrorMock: Error {
        case someError
    }

    private var sut: APIService!

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        self.sut = nil
        super.tearDown()
    }

    func test_whenDataPassed_shouldReturnCorrectData() {
        // given
        let config = MockAPIServiceConfig()
        let expectation = self.expectation(description: "Should return correct data")
        let expectedResponseData = "Response".data(using: .utf8)!
        self.sut = APIService(
            config: config,
            sessionManager: MockAPISessionManager(
                response: nil,
                data: expectedResponseData,
                error: nil)
        )

        // when
        _ = self.sut.request(
            endpoint: MockAPIEndpoint(path: "/path/blabla", method: .get)
        ) { result in
            guard let data = try? result.get()
            else { XCTFail(); return }

            XCTAssertEqual(data, expectedResponseData)
            expectation.fulfill()
        }

        // then
        self.wait(for: [expectation], timeout: 0.1)
    }

    func test_whenNSURLErrorCancelledReturned_shouldReturnCancelledError() {
        // given
        let config = MockAPIServiceConfig()
        let expectation = self.expectation(description: "Should return hasStatusCode error")
        let error: Error = NSError(
            domain: "network",
            code: NSURLErrorCancelled,
            userInfo: nil)
        self.sut = APIService(
            config: config,
            sessionManager: MockAPISessionManager(
                response: nil,
                data: nil,
                error: error)
        )

        // when
        _ = self.sut.request(
            endpoint: MockAPIEndpoint(path: "/path/blabla", method: .get)
        ) { result in
            do {
                _ = try result.get()
                XCTFail()
            } catch let error {
                if case APIServiceError.cancelled = error {
                    expectation.fulfill()
                } else {
                    XCTFail()
                }
            }
        }

        // then
        self.wait(for: [expectation], timeout: 0.1)
    }

    func test_whenStatusCodeGTE400_shouldReturnHasStatusCodeError() {
        // given
        let config = MockAPIServiceConfig()
        let expectation = self.expectation(description: "Should return hasStatusCode error")
        let response = HTTPURLResponse(
            url: URL(string: "https://api.test.com")!,
            statusCode: 401,
            httpVersion: "1.1",
            headerFields: nil)
        self.sut = APIService(
            config: config,
            sessionManager: MockAPISessionManager(
                response: response,
                data: nil,
                error: APIServiceErrorMock.someError)
        )

        // when
        _ = self.sut.request(
            endpoint: MockAPIEndpoint(path: "/path/blabla", method: .get)
        ) { result in
            do {
                _ = try result.get()
                XCTFail()
            } catch let error {
                if case APIServiceError.error(let code, _) = error {
                    XCTAssertEqual(code, 401)
                    expectation.fulfill()
                } else {
                    XCTFail()
                }
            }
        }

        // then
        self.wait(for: [expectation], timeout: 0.1)
    }

    func test_whenNSURLErrorNotConnectedToInternet_shouldReturnNotConnectedError() {
        // given
        let config = MockAPIServiceConfig()
        let expectation = self.expectation(description: "Should return NotConnected error")
        let error: Error = NSError(
            domain: "network",
            code: NSURLErrorNotConnectedToInternet,
            userInfo: nil)
        self.sut = APIService(
            config: config,
            sessionManager: MockAPISessionManager(
                response: nil,
                data: nil,
                error: error)
        )

        // when
        _ = self.sut.request(
            endpoint: MockAPIEndpoint(path: "/path/blabla", method: .get)
        ) { result in
            do {
                _ = try result.get()
                XCTFail()
            } catch let error {
                if case APIServiceError.notConnected = error {
                    expectation.fulfill()
                } else {
                    XCTFail()
                }
            }
        }

        // then
        self.wait(for: [expectation], timeout: 0.1)
    }

    func test_whenStatusCodeUsedWithWrongError_shouldReturnFalse() {
        // when
        let sut = APIServiceError.notConnected

        // then
        XCTAssertFalse(sut.hasStatusCode(200))
    }

    func test_whenStatusCodeUsed_shouldReturnCorrectStatusCode() {
        //when
        let sut = APIServiceError.error(statusCode: 400, data: nil)

        // then
        XCTAssertTrue(sut.hasStatusCode(400))
        XCTAssertFalse(sut.hasStatusCode(399))
        XCTAssertFalse(sut.hasStatusCode(401))
    }

    func test_whenNSURLErrorNotConnectedToInternetReturned_shouldLogError() {
        // given
        let config = MockAPIServiceConfig()
        let expectation = self.expectation(description: "Should log error")
        let error: Error = NSError(
            domain: "network",
            code: NSURLErrorNotConnectedToInternet,
            userInfo: nil)
        let logger = MockAPIServiceErrorLogger()
        self.sut = APIService(
            config: config,
            sessionManager: MockAPISessionManager(
                response: nil,
                data: nil,
                error: error),
            logger: logger
        )

        // when
        _ = self.sut.request(
            endpoint: MockAPIEndpoint(path: "/path/blabla", method: .get)
        ) { result in
            do {
                _ = try result.get()
                XCTFail()
            } catch let error {
                if case APIServiceError.notConnected = error {
                    expectation.fulfill()
                } else {
                    XCTFail()
                }
            }
        }

        // then
        self.wait(for: [expectation], timeout: 0.1)

        let result = logger.loggedErrors.contains { error in
            if case APIServiceError.notConnected = error {
                return true
            } else {
                return false
            }
        }
        XCTAssertTrue(result)
    }
}
