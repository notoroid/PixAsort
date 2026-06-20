//
//  ImportAlbumArt1.swift
//  PixAsort
//
//  Created by 能登 要 on 2026/06/20.
//

import Foundation

struct ImportAlbumArtV1: Decodable {
    let title: String
    let genre: String
    let artwork: String
    let compactArtwork: String
    let year: Int
    let artist: String
    let album: String
}

typealias ImportAlbumArtV1Collection = [ImportAlbumArtV1]
