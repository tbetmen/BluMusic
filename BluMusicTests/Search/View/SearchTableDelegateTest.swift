//
//  SearchTableDelegateTest.swift
//  BluMusicTests
//
//  Created by Muhammad M. Munir on 19/05/24.
//

import UIKit
import XCTest
@testable import BluMusic

final class SearchTableDelegateTest: XCTestCase {
    private var sut: SearchTableDelegate!
    private var viewModel: MockSearchViewModel!
    let tableView = UITableView()
    let indexPath = IndexPath(row: 0, section: 0)

    override func setUp() {
        super.setUp()
        viewModel = MockSearchViewModel()
        sut = SearchTableDelegate()
        sut.viewModel = viewModel
    }

    override func tearDown() {
        sut = nil
        viewModel = nil
        super.tearDown()
    }

    func test_whenCellSelected_shouldHandleSelection() {
        // when
        var result = false
        sut.didSelect = { _ in
            result = true
        }

        // given
        sut.tableView(tableView, didSelectRowAt: indexPath)

        // then
        XCTAssertEqual(sut.tableView(tableView, estimatedHeightForRowAt: indexPath), 100)
        XCTAssertEqual(sut.tableView(tableView, heightForRowAt: indexPath), UITableView.automaticDimension)
        XCTAssertTrue(result)
    }
}
