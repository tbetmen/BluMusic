//
//  SearchTableDelegate.swift
//  BluMusic
//
//  Created by Muhammad M. Munir on 18/05/24.
//

import UIKit

protocol SearchTableDelegateInterface: UITableViewDelegate {
    var didSelect: (SongItem) -> Void { get set }
}

final class SearchTableDelegate: NSObject, SearchTableDelegateInterface {

    var viewModel: SearchViewModelInterface
    var didSelect: (SongItem) -> Void = { _ in }

    init(viewModel: SearchViewModelInterface = SearchViewModel()) {
        self.viewModel = viewModel
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelect(viewModel.songs[indexPath.row])
    }
}
