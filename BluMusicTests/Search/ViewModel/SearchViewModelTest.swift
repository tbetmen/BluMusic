//
//  SearchViewModelTest.swift
//  BluMusicTests
//
//  Created by Muhammad M. Munir on 19/05/24.
//

import XCTest
@testable import BluMusic

final class SearchViewModelTest: XCTestCase {
    private var sut: SearchViewModel!
    private var service: MockSearchService!

    override func setUp() {
        super.setUp()
        self.service = MockSearchService()
        self.sut = SearchViewModel(service: self.service)
    }

    override func tearDown() {
        self.service = nil
        self.sut = nil
        super.tearDown()
    }

    func test_whenInitialView_shouldReturnEmpty() {
        // when
        // then
        XCTAssertEqual(self.sut.resultState, .empty)
    }

    func test_whenFailedToFetch_shouldReturnError() {
        // when
        self.service.isSuccess = false

        // then
        self.sut.search("test") {
            XCTAssertEqual(self.sut.resultState, .error)
        }
    }

    func test_whenLoading_shouldReturnLoading() {
        // when
        self.service.isSuccess = false
        self.sut.resultState = .loading

        // then
        XCTAssertEqual(self.sut.resultState, .loading)
        self.sut.search("test") {
            XCTAssertEqual(self.sut.resultState, .error)
        }
    }

    func test_whenSongsNotFound_shouldReturnEmpty() {
        // when
        self.service.isSuccess = true
        self.service.songs = []

        // then
        self.sut.search("test") {
            XCTAssertEqual(self.sut.resultState, .empty)
            XCTAssertTrue(self.sut.songs.isEmpty)
        }
    }

    func test_whenSongsFound_shouldReturnSongs() {
        // when
        self.service.isSuccess = true

        // then
        self.sut.search("test") {
            XCTAssertEqual(self.sut.resultState, .songs)
            XCTAssertEqual(self.sut.songs.count, 2)
        }
    }
}
