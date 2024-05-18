//
//  SearchViewController.swift
//  BluMusic
//
//  Created by Muhammad M. Munir on 18/05/24.
//

import UIKit

final class SearchViewController: UIViewController {

    private lazy var tableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.black
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 120, right: 0)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = tableDataSource
        tableView.delegate = tableDelegate
        tableView.register(
            SongRowCell.self,
            forCellReuseIdentifier: SongRowCell.reuseIdentifier)
        tableView.register(
            SongEmptyCell.self,
            forCellReuseIdentifier: SongEmptyCell.reuseIdentifier
        )
        tableView.register(
            SongLoadingCell.self,
            forCellReuseIdentifier: SongLoadingCell.reuseIdentifier
        )
        return tableView
    }()

    private var timer: Timer?
    private let searchController = UISearchController(searchResultsController: nil)

    weak var tabBarDelegate: MainTabBarControllerDelegate?

    private var viewModel: SearchViewModelInterface = SearchViewModel()
    var tableDataSource: SearchTableDataSourceInterface = SearchTableDataSource()
    var tableDelegate: SearchTableDelegate = SearchTableDelegate()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "BluMusic"
        view.backgroundColor = UIColor.black
        setupConstraint()
        setupSearchBar()
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    private func setupConstraint() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor),
        ])
    }

    private func setupSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
    }

    private func setupTableView() {
        tableDataSource.viewModel = viewModel
        tableDelegate.viewModel = viewModel
        tableDelegate.didSelect = { [weak self] song in
            self?.tabBarDelegate?.maximizedPlayer(song: song)
        }
        tableView.reloadData()
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(
            withTimeInterval: 0.5,
            repeats: false,
            block: { [weak self] _ in
                self?.viewModel.resultState = .loading
                self?.tableView.reloadData()
                self?.viewModel.search(searchText) {
                    self?.tableView.reloadData()
                }
        })
    }
}

// MARK: - SongPlayerDelegate

extension SearchViewController: SongPlayerDelegate {
    
    private func getSong(isForward: Bool) -> SongItem? {
        guard let indexPath = tableView.indexPathForSelectedRow else { return nil }
        tableView.deselectRow(at: indexPath, animated: true)
        var nextIndexPath: IndexPath
        if isForward {
            nextIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
            if nextIndexPath.row == viewModel.songs.count {
                nextIndexPath.row = 0
            }
        } else {
            nextIndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
            if nextIndexPath.row == -1 {
                nextIndexPath.row = viewModel.songs.count - 1
            }
        }
        tableView.selectRow(at: nextIndexPath, animated: true, scrollPosition: .none)

        let cellViewModel = viewModel.songs[nextIndexPath.row]
        return cellViewModel
    }

    func moveToPrevious() -> SongItem? {
        getSong(isForward: false)
    }

    func moveToNext() -> SongItem? {
        getSong(isForward: true)
    }
}
