//
//  SearchTableDataSourceTest.swift
//  BluMusicTests
//
//  Created by Muhammad M. Munir on 19/05/24.
//

import XCTest
@testable import BluMusic

final class SearchTableDataSourceTest: XCTestCase {
    var sut: SearchTableDataSource!
    var viewModel: MockSearchViewModel!
    var tableView: UITableView!

    override func setUp() {
        super.setUp()
        viewModel = MockSearchViewModel()
        tableView = UITableView()
        tableView.register(
            SongRowCell.self,
            forCellReuseIdentifier: SongRowCell.reuseIdentifier)
        tableView.register(
            SongLoadingCell.self,
            forCellReuseIdentifier: SongLoadingCell.reuseIdentifier)
        tableView.register(
            SongEmptyCell.self,
            forCellReuseIdentifier: SongEmptyCell.reuseIdentifier)

        sut = SearchTableDataSource()
        sut.viewModel = viewModel
    }

    override func tearDown() {
        sut = nil
        viewModel = nil
        tableView = nil
        super.tearDown()
    }

    func test_whenSongsNotFound_shouldShowEmpty() {
        viewModel.resultState = .empty
        viewModel.songs = []

        XCTAssertEqual(sut.tableView(tableView, numberOfRowsInSection: 0), 1)
        let cell = sut.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as! SongEmptyCell
        XCTAssertEqual(cell.emptyTitle.text, "Please enter song name or artist ...")
    }

    func test_whenAPIError_shouldShowError() {
        viewModel.resultState = .error
        viewModel.songs = []

        XCTAssertEqual(sut.tableView(tableView, numberOfRowsInSection: 0), 1)
        let cell = sut.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as! SongEmptyCell
        XCTAssertEqual(cell.emptyTitle.text, "There is error while fetching song, please try again later.")
    }

    func test_whenFetchingAPI_shouldShowLoading() {
        viewModel.resultState = .loading
        viewModel.songs = []

        XCTAssertEqual(sut.tableView(tableView, numberOfRowsInSection: 0), 1)
        let cell = sut.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as! SongLoadingCell
        XCTAssertEqual(cell.loadingLabel.text, "LOADING...")
    }

    func test_whenSongsFound_shouldShowSongs() {
        viewModel.resultState = .songs

        XCTAssertEqual(sut.tableView(tableView, numberOfRowsInSection: 0), 2)
        let cell = sut.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as! SongRowCell
        XCTAssertEqual(cell.songTitle.text, "trackName")
        let cell2 = sut.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0)) as! SongRowCell
        XCTAssertEqual(cell2.songTitle.text, "trackName2")
    }
}
