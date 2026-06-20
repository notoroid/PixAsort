//
//  AlbumArtSeeder.swift
//  PixAsort
//
//  Created by 能登 要 on 2026/06/20.
//

import Foundation
import SwiftData

/// アプリ初期化時に `AlbumArt` コレクションを準備するためのシード処理。
enum AlbumArtSeeder {
    /// `AlbumArt` コレクションが空かどうかを確認し、空の場合は
    /// バンドル同梱の `Starbucks.json` を読み込んで保存する。
    ///
    /// Starbucks の内容は更新される場合があるため、JSON のデコードには
    /// `ImportAlbumArt1Collection` を使用する。
    static func seedIfNeeded(in context: ModelContext) {
        do {
            // 既に1件でも保存済みなら何もしない。
            var descriptor = FetchDescriptor<AlbumArt>()
            descriptor.fetchLimit = 1
            let existingCount = try context.fetchCount(descriptor)
            guard existingCount == 0 else { return }

            // バンドルから Starbucks.json を読み込む。
            guard let url = Bundle.main.url(forResource: "Starbucks", withExtension: "json") else {
                print("AlbumArtSeeder: Starbucks.json がバンドルに見つかりませんでした。")
                return
            }

            let data = try Data(contentsOf: url)
            let imported = try JSONDecoder().decode(ImportAlbumArtV1Collection.self, from: data)

            // デコードした各要素を AlbumArt に変換して保存する。
            for item in imported {
                let albumArt = AlbumArt(
                    uniqueID: UUID(),
                    title: item.title,
                    genre: item.genre,
                    artwork: strippedFileName(from: item.artwork),
                    compactArtwork: strippedFileName(from: item.compactArtwork),
                    year: item.year,
                    artist: item.artist,
                    album: item.album
                )
                context.insert(albumArt)
            }

            try context.save()
        } catch {
            print("AlbumArtSeeder: シード処理に失敗しました: \(error)")
        }
    }

    /// フォルダ指定を除去してファイル名のみを返す。
    /// 例: "Starbucks.files/041-compact.png" -> "041-compact.png"
    private static func strippedFileName(from path: String) -> String {
        (path as NSString).lastPathComponent
    }
}
