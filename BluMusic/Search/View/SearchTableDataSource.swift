//
//  SearchTableDataSource.swift
//  BluMusic
//
//  Created by Muhammad M. Munir on 18/05/24.
//

import UIKit

protocol SearchTableDataSourceInterface: UITableViewDataSource {
    var viewModel: SearchViewModelInterface { get set }
}

final class SearchTableDataSource: NSObject, SearchTableDataSourceInterface {
    var viewModel: SearchViewModelInterface

    init(viewModel: SearchViewModelInterface = SearchViewModel()) {
        self.viewModel = viewModel
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch viewModel.resultState {
        case .songs:
            return viewModel.songs.count
        default:
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewModel.resultState {
        case .songs:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: SongRowCell.reuseIdentifier, for: indexPath) as! SongRowCell
            let song = viewModel.songs[indexPath.row]
            cell.setupContent(
                thumbnailURL: song.artworkUrl100,
                songTitle: song.trackName,
                artist: song.artistName,
                album: song.collectionName
            )
            return cell
        case .loading:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: SongLoadingCell.reuseIdentifier, for: indexPath) as! SongLoadingCell
            cell.animating()
            return cell
        case .error:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: SongEmptyCell.reuseIdentifier, for: indexPath) as! SongEmptyCell
            cell.setup(isError: true)
            return cell
        case .empty:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: SongEmptyCell.reuseIdentifier, for: indexPath) as! SongEmptyCell
            cell.setup()
            return cell
        }
    }
}
