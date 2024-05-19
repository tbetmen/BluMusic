//
//  APIPathTest.swift
//  BluMusicTests
//
//  Created by Muhammad M. Munir on 19/05/24.
//

import XCTest
@testable import BluMusic

final class APIPathTests: XCTestCase {
    func test_searchPath() {
        XCTAssertEqual(APIPath.search.rawValue, "search")
    }
}
