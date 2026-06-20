//
//  AlbumArt.swift
//  PixAsort
//
//  Created by 能登 要 on 2026/06/20.
//

import Foundation
import SwiftData

@Model
final class AlbumArt: Codable {
    /// アプリ内で各 AlbumArt を一意に参照するための識別子。
    @Attribute(.unique) var uniqueID: UUID
    var title: String
    var genre: String
    var artwork: String
    var compactArtwork: String
    var year: Int
    var artist: String
    var album: String
    /// お気に入りフラグ。`.photos.updateAsset` および UI から切り替える。
    var isFavorite: Bool
    /// 非表示フラグ。true の場合は一覧から除外する（`.photos.updateAsset` 対応）。
    var isHidden: Bool

    init(
        uniqueID: UUID = UUID(),
        title: String,
        genre: String,
        artwork: String,
        compactArtwork: String,
        year: Int,
        artist: String,
        album: String,
        isFavorite: Bool = false,
        isHidden: Bool = false
    ) {
        self.uniqueID = uniqueID
        self.title = title
        self.genre = genre
        self.artwork = artwork
        self.compactArtwork = compactArtwork
        self.year = year
        self.artist = artist
        self.album = album
        self.isFavorite = isFavorite
        self.isHidden = isHidden
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case uniqueID
        case title
        case genre
        case artwork
        case compactArtwork
        case year
        case artist
        case album
        case isFavorite
        case isHidden
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // JSON に uniqueID が含まれない場合は新規に採番する。
        self.uniqueID = try container.decodeIfPresent(UUID.self, forKey: .uniqueID) ?? UUID()
        self.title = try container.decode(String.self, forKey: .title)
        self.genre = try container.decode(String.self, forKey: .genre)
        self.artwork = try container.decode(String.self, forKey: .artwork)
        self.compactArtwork = try container.decode(String.self, forKey: .compactArtwork)
        self.year = try container.decode(Int.self, forKey: .year)
        self.artist = try container.decode(String.self, forKey: .artist)
        self.album = try container.decode(String.self, forKey: .album)
        // 既存 JSON との互換のため、未指定なら false とする。
        self.isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
        self.isHidden = try container.decodeIfPresent(Bool.self, forKey: .isHidden) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uniqueID, forKey: .uniqueID)
        try container.encode(title, forKey: .title)
        try container.encode(genre, forKey: .genre)
        try container.encode(artwork, forKey: .artwork)
        try container.encode(compactArtwork, forKey: .compactArtwork)
        try container.encode(year, forKey: .year)
        try container.encode(artist, forKey: .artist)
        try container.encode(album, forKey: .album)
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encode(isHidden, forKey: .isHidden)
    }
}
