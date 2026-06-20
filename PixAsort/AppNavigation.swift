//
//  AppNavigation.swift
//  PixAsort
//
//  Created by 能登 要 on 2026/06/20.
//

import Foundation
import Observation

/// App Intents からアプリの画面遷移・検索状態を駆動するための共有モデル。
///
/// `OpenAlbumArtIntent` や `SearchAlbumArtIntent` はビュー階層の外で実行されるため、
/// この共有オブジェクトを介して `ContentView` の選択状態・検索テキストを更新する。
@MainActor
@Observable
final class AppNavigation {
    static let shared = AppNavigation()

    /// 詳細表示中の AlbumArt の `uniqueID`。`OpenAlbumArtIntent` から設定する。
    var selectedAlbumArtID: UUID?

    /// 一覧の検索テキスト。`SearchAlbumArtIntent` から設定する。
    var searchText: String = ""

    private init() {}
}
