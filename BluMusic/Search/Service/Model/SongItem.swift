//
//  SongItem.swift
//  BluMusic
//
//  Created by Muhammad M. Munir on 18/05/24.
//

import Foundation

struct SongItem {
    var trackName: String
    var collectionName: String
    var artistName: String
    var artworkUrl100: String
    var previewUrl: String
    var artworkUrl500: String {
        artworkUrl100.replacingOccurrences(of: "100x100", with: "500x500")
    }
}
