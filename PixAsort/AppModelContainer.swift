//
//  AppModelContainer.swift
//  PixAsort
//
//  Created by 能登 要 on 2026/06/20.
//

import Foundation
import SwiftData

/// アプリ本体と App Intents の両方から参照する共有の `ModelContainer`。
///
/// App Intents（`OpenAlbumArtIntent` や `UpdateAlbumArtIntent` など）は
/// SwiftUI のビュー階層の外で実行されるため、`@Environment(\.modelContext)` を
/// 使えない。同一のオンディスクストアへアクセスするために、ここで単一の
/// コンテナを共有する。
enum AppModelContainer {
    /// アプリ全体で共有する `ModelContainer`。
    static let shared: ModelContainer = {
        let schema = Schema([
            AlbumArt.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
#if DEBUG
            // 開発中のスキーマ変更でマイグレーションに失敗した場合の暫定対処。
            // オンディスクのストアを削除してから作り直す。
            // リリースビルドでは誤ってユーザーデータを消さないよう、この処理は行わない。
            print("ModelContainer の生成に失敗したためストアを削除して再生成します: \(error)")
            deleteStore(at: modelConfiguration.url)
            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("ストア削除後も ModelContainer を生成できませんでした: \(error)")
            }
#else
            fatalError("Could not create ModelContainer: \(error)")
#endif
        }
    }()

#if DEBUG
    /// SwiftData のオンディスクストア本体と関連ファイル（-shm / -wal）を削除する。
    /// マイグレーション失敗時の開発用リカバリ専用。
    private static func deleteStore(at url: URL) {
        let fileManager = FileManager.default
        // SQLite 本体に加え、WAL モードのジャーナル系サイドカーファイルも削除する。
        for suffix in ["", "-shm", "-wal"] {
            let target = URL(fileURLWithPath: url.path + suffix)
            try? fileManager.removeItem(at: target)
        }
    }
#endif
}
