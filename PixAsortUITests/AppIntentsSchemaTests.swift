//
//  AppIntentsSchemaTests.swift
//  PixAsortUITests
//
//  Created by 能登 要 on 2026/06/20.
//

import AppIntentsTesting
import XCTest

/// AppIntentsTesting を用いた AppSchema（photo ドメイン）の各 Intent テスト。

final class AppIntentsSchemaTests: XCTestCase {
    let definitions = IntentDefinitions(bundleIdentifier: "com.irimasu.PixAsort")
    
    /// `.system.search` スキーマの検索 Intent が実行できることを確認する。
    func testSearchIntentRuns() async throws {
        let searchAlbumArtIntentDefinition = definitions.intents["SearchAlbumArtIntent"]
        let searchAlbumArtIntentIntent = searchAlbumArtIntentDefinition.makeIntent(criteria: "ジャズ")
        let result = try await searchAlbumArtIntentIntent.run()
        
        _ = result
    }

    /// `.photos.openAsset` スキーマの Intent でアセットを開けることを確認する。
    func testOpenAssetIntentRuns() async throws {
        let entityDefinition = definitions.entities["AlbumArtEntity"]
        let suggestedEntities = try await entityDefinition.suggestedEntities()
        let target = suggestedEntities.first
        
        let intent = definitions.intents["OpenAlbumArtIntent"].makeIntent(target: target)
        let result = try await intent.run()
        
        _ = result
    }

    /// `.photos.updateAsset` スキーマの Intent でお気に入りを更新できることを確認する。
    /// 更新が成功し、差分インデックスが走っても例外が出ないことを検証する。
    func testUpdateAssetIntentTogglesFavorite() async throws {
        let entityDefinition = definitions.entities["AlbumArtEntity"]
        let suggestedEntities = try await entityDefinition.suggestedEntities()
        let target = suggestedEntities.first

        let updateAlbumArtDefinition = definitions.intents["UpdateAlbumArtIntent"]
        let updateAlbumArtIntent = updateAlbumArtDefinition.makeIntent(target: [target], isFavorite: true)
        let result = try await updateAlbumArtIntent.run()
        
        _ = result
    }
}
