//
//  SearchServiceTest.swift
//  BluMusicTests
//
//  Created by Muhammad M. Munir on 19/05/24.
//

import XCTest
@testable import BluMusic

final class SearchServiceTest: XCTestCase {
    private var sut: SearchService!
    private var dataTransfer: MockDataTransferService!

    override func setUp() {
        super.setUp()
        self.dataTransfer = MockDataTransferService(
            dto: SearchResponseDTO(
                resultCount: 2,
                results: [
                    SearchResponseDTO.Track(trackName: "Numb", artistName: "Linkin Park"),
                    SearchResponseDTO.Track(trackName: "Iridescent", artistName: "Linkin Park"),
                ]
            )
        )
        self.sut = SearchService(transferService: dataTransfer)
    }

    override func tearDown() {
        self.dataTransfer = nil
        self.sut = nil
        super.tearDown()
    }

    func test_whenFailedToDecoded_shouldReturnError() {
        // when
        self.dataTransfer.isSuccess = false

        // then
        _ = self.sut.search("test") { result in
            if case .failure(_) = result {
                XCTAssertTrue(true)
            }
        }
    }

    func test_whenSucceedDecoded_shouldReturnSongs() {
        // when
        self.dataTransfer.isSuccess = true

        // then
        _ = self.sut.search("test") { result in
            if case .success(let songs) = result {
                XCTAssertTrue(songs.count == 2)
                XCTAssertEqual(songs[0].trackName, "Numb")
                XCTAssertTrue(songs[0].artworkUrl500.isEmpty)
                XCTAssertEqual(songs[1].trackName, "Iridescent")
            }
        }
    }
}
