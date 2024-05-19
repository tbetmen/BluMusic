//
//  DataTransferServiceTests.swift
//  BluMusicTests
//
//  Created by Muhammad M. Munir on 19/05/24.
//

import XCTest
@testable import BluMusic

final class DataTransferServiceTests: XCTestCase {

    struct MockModel: Decodable {
        let name: String
    }

    enum DataTransferErrorMock: Error {
        case someError
    }

    private var sut: DataTransferService!

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        self.sut = nil
        super.tearDown()
    }

    func test_whenReceivedValidResponse_thenDecodeToDecodableObject() {
        // given
        let config = MockAPIServiceConfig()
        let expectation = self.expectation(description: "Should decode response")
        // this is valid response of MockModel
        let responseData = #"{"name": "Test"}"#.data(using: .utf8)
        let apiService = APIService(
            config: config,
            sessionManager: MockAPISessionManager(
                response: nil,
                data: responseData,
                error: nil)
        )
        self.sut = DataTransferService(apiService: apiService)

        // when
        _ = self.sut.request(
            with: APIEndpoint<MockModel>(path: "/path/blabla", method: .get)
        ) { result in
            do {
                let object = try result.get()
                XCTAssertEqual(object.name, "Test")
                expectation.fulfill()
            } catch {
                XCTFail()
            }
        }

        // then
        self.wait(for: [expectation], timeout: 0.1)
    }

    func test_whenReceivedInvalidResponse_thenNotDecodeObject() {
        // given
        let config = MockAPIServiceConfig()
        let expectation = self.expectation(description: "Should not decode response")
        // this is invalid response of MockModel
        let responseData = #"{"username": "test"}"#.data(using: .utf8)
        let apiService = APIService(
            config: config,
            sessionManager: MockAPISessionManager(
                response: nil,
                data: responseData,
                error: nil)
        )
        self.sut = DataTransferService(apiService: apiService)

        // when
        _ = self.sut.request(
            with: APIEndpoint<MockModel>(path: "/path/blabla", method: .get)
        ) { result in
            do {
                _ = try result.get()
                XCTFail()
            } catch {
                expectation.fulfill()
            }
        }

        // then
        self.wait(for: [expectation], timeout: 0.1)
    }

    func test_whenBadRequest_shouldThrowNetworkError() {
        // given
        let config = MockAPIServiceConfig()
        let expectation = self.expectation(description: "Should throw network error")
        let responseData = #"{"invalid": "invalid"}"#.data(using: .utf8)
        let response = HTTPURLResponse(
            url: URL(string: "https://api.test.com")!,
            statusCode: 500,
            httpVersion: "1.1",
            headerFields: nil)
        let apiService = APIService(
            config: config,
            sessionManager: MockAPISessionManager(
                response: response,
                data: responseData,
                error: DataTransferErrorMock.someError)
        )
        self.sut = DataTransferService(apiService: apiService)

        // when
        _ = self.sut.request(
            with: APIEndpoint<MockModel>(path: "/path/blabla", method: .get)
        ) { result in
            do {
                _ = try result.get()
                XCTFail()
            } catch let error {
                if case DataTransferError.networkFailure(
                    APIServiceError.error(statusCode: 500, _)
                ) = error {
                    expectation.fulfill()
                } else {
                    XCTFail()
                }
            }
        }

        // then
        self.wait(for: [expectation], timeout: 0.1)
    }

    func test_whenNoDataReceived_shouldThrowNoDataError() {
        // given
        let config = MockAPIServiceConfig()
        let expectation = self.expectation(description: "Should throw no data error")
        let response = HTTPURLResponse(
            url: URL(string: "https://api.test.com")!,
            statusCode: 200,
            httpVersion: "1.1",
            headerFields: nil)
        let apiService = APIService(
            config: config,
            sessionManager: MockAPISessionManager(
                response: response,
                data: nil,
                error: nil)
        )
        self.sut = DataTransferService(apiService: apiService)

        // when
        _ = self.sut.request(
            with: APIEndpoint<MockModel>(path: "/path/blabla", method: .get)
        ) { result in
            do {
                _ = try result.get()
                XCTFail()
            } catch let error {
                if case DataTransferError.noResponse = error {
                    expectation.fulfill()
                } else {
                    XCTFail()
                }
            }
        }

        // then
        self.wait(for: [expectation], timeout: 0.1)
    }
}
