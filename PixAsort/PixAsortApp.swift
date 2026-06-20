//
//  PixAsortApp.swift
//  PixAsort
//
//  Created by 能登 要 on 2026/06/20.
//

import SwiftUI
import SwiftData

@main
struct PixAsortApp: App {
    /// アプリ本体と App Intents で共有する `ModelContainer`。
    let sharedModelContainer = AppModelContainer.shared

    init() {
        // AlbumArt コレクションが空であれば Starbucks.json を読み込んで保存する。
        AlbumArtSeeder.seedIfNeeded(in: sharedModelContainer.mainContext)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
