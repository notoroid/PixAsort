//
//  AlbumArtAppIntents.swift
//  PixAsort
//
//  Created by 能登 要 on 2026/06/20.
//

import AppIntents
import Foundation
import SwiftData

/// `.system.search` スキーマ。アプリ内検索の結果を表示する。
/// 既存の `.searchable`（title / album / artist / genre / year 横断）へ
/// 検索語を引き渡す。
@AppIntent(schema: .system.search)
struct SearchAlbumArtIntent: ShowInAppSearchResultsIntent {
    static let searchScopes: [StringSearchScope] = [.general]

    var criteria: StringSearchCriteria

    @MainActor
    func perform() async throws -> some IntentResult {
        AppNavigation.shared.searchText = criteria.term
        return .result()
    }
}

/// `.photos.openAsset` スキーマ。指定した AlbumArt の詳細画面を開く。
@AppIntent(schema: .photos.openAsset)
struct OpenAlbumArtIntent: OpenIntent {
    var target: AlbumArtEntity

    @MainActor
    func perform() async throws -> some IntentResult {
        AppNavigation.shared.selectedAlbumArtID = target.id
        return .result()
    }
}

/// `.photos.updateAsset` スキーマ。AlbumArt の名前 / 非表示 / お気に入りを更新する。
@AppIntent(schema: .photos.updateAsset)
struct UpdateAlbumArtIntent {
    var target: [AlbumArtEntity]
    var name: String?
    var isHidden: Bool?
    var isFavorite: Bool?

    @MainActor
    func perform() async throws -> some IntentResult {
        let context = AppModelContainer.shared.mainContext
        let identifiers = target.map(\.id)
        let descriptor = FetchDescriptor<AlbumArt>(
            predicate: #Predicate { identifiers.contains($0.uniqueID) }
        )
        let matches = try context.fetch(descriptor)

        for albumArt in matches {
            if let name { albumArt.title = name }
            if let isHidden { albumArt.isHidden = isHidden }
            if let isFavorite { albumArt.isFavorite = isFavorite }
        }

        if context.hasChanges {
            try context.save()
        }
        return .result()
    }
}
