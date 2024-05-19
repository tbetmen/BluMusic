//
//  MockSearchService.swift
//  BluMusicTests
//
//  Created by Muhammad M. Munir on 19/05/24.
//

@testable import BluMusic

final class MockSearchService: SearchServiceInterface {
    var songs = [
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
    var isSuccess: Bool = false

    func search(
        _ query: String,
        completion: @escaping (Result<[SongItem], Error>) -> Void
    ) -> APIServiceCancellableInterface? {
        if isSuccess {
            completion(.success(songs))
        } else {
            completion(.failure(APIServiceError.urlGeneration))
        }
        return nil
    }
}
