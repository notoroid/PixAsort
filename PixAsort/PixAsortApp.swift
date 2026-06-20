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
    var sharedModelContainer: ModelContainer = {
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
