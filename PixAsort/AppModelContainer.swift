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
            Item.self,
            AlbumArt.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}
