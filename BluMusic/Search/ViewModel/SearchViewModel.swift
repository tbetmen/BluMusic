//
//  SearchViewModel.swift
//  BluMusic
//
//  Created by Muhammad M. Munir on 18/05/24.
//

import Foundation

protocol SearchViewModelInterface {
    var songs: [SongItem] { get }
    var resultState: SearchViewModel.ResultState { get set }

    func search(_ query: String, completion: @escaping () -> Void)
}

final class SearchViewModel: SearchViewModelInterface {
    private let searchService: SearchServiceInterface
    private var searchTask: APIServiceCancellableInterface? {
        willSet {
            self.searchTask?.cancel()
        }
    }

    enum ResultState {
        case songs
        case loading
        case error
        case empty
    }

    var songs = [SongItem]()
    var resultState: ResultState = .empty

    init(service: SearchServiceInterface = SearchService()) {
        self.searchService = service
    }

    func search(_ query: String, completion: @escaping () -> Void) {
        guard !query.isEmpty else { return }
        searchService.search(query) { [weak self] result in
            switch result {
            case .success(let songs):
                self?.songs = songs
                self?.resultState = songs.isEmpty ? .empty : .songs
            case .failure:
                self?.resultState = .error
            }
            completion()
        }
    }
}
