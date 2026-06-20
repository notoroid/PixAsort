//
//  PhotoAssetType.swift
//  PixAsort
//
//  Created by 能登 要 on 2026/06/20.
//

import AppIntents

/// `.photos.assetType` スキーマに準拠したアセット種別。
/// アルバムアートはすべて静止画のため `photo` のみを使用する。
@AppEnum(schema: .photos.assetType)
enum PhotoAssetType: String {
    case photo
    case video

    static let caseDisplayRepresentations: [PhotoAssetType: DisplayRepresentation] = [
        .photo: "Photo",
        .video: "Video",
    ]
}
