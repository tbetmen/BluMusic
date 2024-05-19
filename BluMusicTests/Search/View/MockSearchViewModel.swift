//
//  MockSearchViewModel.swift
//  BluMusicTests
//
//  Created by Muhammad M. Munir on 19/05/24.
//

@testable import BluMusic

final class MockSearchViewModel: SearchViewModelInterface {
    var songs: [SongItem] = [
        SongItem(
            trackName: "trackName",
            collectionName: "collectionName",
            artistName: "artistName",
            artworkUrl100: "artworkUrl100",
            previewUrl: "previewUrl"
        ),
        SongItem(
            trackName: "trackName2",
            collectionName: "collectionName2",
            artistName: "artistName2",
            artworkUrl100: "artworkUrl1002",
            previewUrl: "previewUrl2"
        ),
    ]
    var resultState: SearchViewModel.ResultState = .empty

    func search(_ query: String, completion: @escaping () -> Void) {}
}
