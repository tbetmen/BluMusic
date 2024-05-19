//
//  APIServiceConfigTests.swift
//  BluMusicTests
//
//  Created by Muhammad M. Munir on 19/05/24.
//

import XCTest
@testable import BluMusic

final class APIServiceConfigTests: XCTestCase {

    private var sut: APIServiceConfig!

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        self.sut = nil
        super.tearDown()
    }

    func test_initWithBaseURL() {
        self.sut = APIServiceConfig(baseURL: "baseUrl")

        XCTAssertEqual(self.sut.baseURL, "baseUrl")
        XCTAssertEqual(self.sut.headers, [:])
        XCTAssertEqual(self.sut.queryParams, [:])
    }

    func test_initWithAllParam() {
        self.sut = APIServiceConfig(
            baseURL: "baseURLImage",
            headers: ["headerKey": "headerValue"],
            queryParams: ["paramKey": "paramValue"]
        )

        XCTAssertEqual(self.sut.baseURL, "baseURLImage")
        XCTAssertEqual(self.sut.headers, ["headerKey": "headerValue"])
        XCTAssertEqual(self.sut.queryParams, ["paramKey": "paramValue"])
    }

    func test_factory() {
        let config = APIServiceConfig.create()

        XCTAssertEqual(config.baseURL, APIConfig.baseURL)
        XCTAssertEqual(config.headers, [:])
        XCTAssertEqual(config.queryParams, [:])
    }
}
