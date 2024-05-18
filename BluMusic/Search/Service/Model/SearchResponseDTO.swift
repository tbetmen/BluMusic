//
//  SearchResponseDTO.swift
//  BluMusic
//
//  Created by Muhammad M. Munir on 18/05/24.
//

import Foundation

struct SearchResponseDTO: Decodable {
    var resultCount: Int
    var results: [Track]

    struct Track: Decodable {
        var trackName: String
        var collectionName: String?
        var artistName: String
        var artworkUrl100: String?
        var previewUrl: String?
    }
}

extension SearchResponseDTO {
    func toEntity() -> [SongItem] {
        self.results.map {
            SongItem(
                trackName: $0.trackName,
                collectionName: $0.collectionName ?? "",
                artistName: $0.artistName,
                artworkUrl100: $0.artworkUrl100 ?? "",
                previewUrl: $0.previewUrl ?? ""
            )
        }
    }
}
