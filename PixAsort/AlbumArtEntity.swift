//
//  AlbumArtEntity.swift
//  PixAsort
//
//  Created by 能登 要 on 2026/06/20.
//

import AppIntents
import CoreLocation
import Foundation
import SwiftData

/// `.photos.asset` スキーマに準拠した AlbumArt のエンティティ表現。
/// Siri / Apple Intelligence / Spotlight から AlbumArt を「写真アセット」として
/// 参照できるようにする。
@AppEntity(schema: .photos.asset)
struct AlbumArtEntity: IndexedEntity {
    static let defaultQuery = AlbumArtEntityQuery()

    /// AlbumArt.uniqueID をそのまま識別子に用いる。
    let id: UUID

    @Property(title: "Title")
    var title: String?

    var creationDate: Date?
    var location: CLPlacemark?
    var assetType: PhotoAssetType?
    var isFavorite: Bool
    var isHidden: Bool
    var hasSuggestedEdits: Bool
    // 以下はカメラ撮影パラメータ。PixAsort は編集機能を持たないため常に未設定。
    var aperture: Double?
    var exposure: Double?
    var saturation: Double?
    var warmth: Double?
    var filter: PhotoFilterEffectType?
    var isPortraitModeEnabled: Bool?

    /// スキーマプロパティは `@Property` でラップされ、合成のメンバーワイズ
    /// イニシャライザが `EntityProperty` 型を要求するため、素の値を受け取る
    /// イニシャライザを明示的に用意する。
    init(
        id: UUID,
        title: String?,
        creationDate: Date?,
        location: CLPlacemark?,
        assetType: PhotoAssetType?,
        isFavorite: Bool,
        isHidden: Bool,
        hasSuggestedEdits: Bool,
        aperture: Double? = nil,
        exposure: Double? = nil,
        saturation: Double? = nil,
        warmth: Double? = nil,
        filter: PhotoFilterEffectType? = nil,
        isPortraitModeEnabled: Bool? = nil
    ) {
        self.id = id
        self.title = title
        self.creationDate = creationDate
        self.location = location
        self.assetType = assetType
        self.isFavorite = isFavorite
        self.isHidden = isHidden
        self.hasSuggestedEdits = hasSuggestedEdits
        self.aperture = aperture
        self.exposure = exposure
        self.saturation = saturation
        self.warmth = warmth
        self.filter = filter
        self.isPortraitModeEnabled = isPortraitModeEnabled
    }

    /// 一覧やパラメータ確認時に表示する内容。
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(title ?? "Album Art")",
            subtitle: assetType?.localizedStringResource ?? "Photo"
        )
    }
}

extension AlbumArt {
    /// SwiftData モデルから App Intents のエンティティへ変換する。
    var entity: AlbumArtEntity {
        AlbumArtEntity(
            id: uniqueID,
            title: title,
            creationDate: nil,
            location: nil,
            assetType: .photo,
            isFavorite: isFavorite,
            isHidden: isHidden,
            hasSuggestedEdits: false
        )
    }
}

/// `AlbumArtEntity` を識別子から取得するためのクエリ。
struct AlbumArtEntityQuery: EntityQuery {
    @MainActor
    func entities(for identifiers: [AlbumArtEntity.ID]) async throws -> [AlbumArtEntity] {
        let context = AppModelContainer.shared.mainContext
        let descriptor = FetchDescriptor<AlbumArt>(
            predicate: #Predicate { identifiers.contains($0.uniqueID) }
        )
        return try context.fetch(descriptor).map(\.entity)
    }

    @MainActor
    func suggestedEntities() async throws -> [AlbumArtEntity] {
        let context = AppModelContainer.shared.mainContext
        var descriptor = FetchDescriptor<AlbumArt>(
            predicate: #Predicate { $0.isHidden == false },
            sortBy: [SortDescriptor(\.title)]
        )
        descriptor.fetchLimit = 5
        return try context.fetch(descriptor).map(\.entity)
    }
}
