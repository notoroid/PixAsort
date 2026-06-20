//
//  PixAsortShortcuts.swift
//  PixAsort
//
//  Created by 能登 要 on 2026/06/20.
//

import AppIntents

/// Siri / Spotlight / ショートカット App へアプリのアクションを公開する。
/// スキーマ準拠の各 Intent は Apple Intelligence からも自動的に利用できるが、
/// 発話フレーズを提供することで明示的に呼び出せるようにする。
struct PixAsortShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: SearchAlbumArtIntent(),
            phrases: [
                "Search \(.applicationName)",
                "Find album art in \(.applicationName)",
            ],
            shortTitle: "Search Album Art",
            systemImageName: "magnifyingglass"
        )
    }
}
