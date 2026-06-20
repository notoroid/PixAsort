//
//  PhotoFilterEffectType.swift
//  PixAsort
//
//  Created by 能登 要 on 2026/06/20.
//

import AppIntents

/// `.photos.filterType` スキーマに準拠したフィルター種別。
/// PixAsort はフィルター編集機能を持たないため `none` のみを提供する。
@AppEnum(schema: .photos.filterType)
enum PhotoFilterEffectType: String {
    case none

    static let caseDisplayRepresentations: [PhotoFilterEffectType: DisplayRepresentation] = [
        .none: "None",
    ]
}
