//
//  ArtworkImage.swift
//  PixAsort
//
//  Created by 能登 要 on 2026/06/20.
//

import SwiftUI

/// バンドルリソースのアートワーク画像を表示する再利用可能なビュー。
/// ピクセルアートを鮮明に表示するため `.interpolation(.none)` を付加する。
/// サイズ指定は呼び出し側で行う（`.resizable()` 済みの画像を返す）。
struct ArtworkImage: View {
    let name: String

    var body: some View {
        if let image = Self.loadImage(named: name) {
            image
                .interpolation(.none)
                .resizable()
        } else {
            // 画像が見つからない場合のプレースホルダー。
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.secondary)
        }
    }

    /// バンドルリソースからファイル名で画像を読み込む。
    static func loadImage(named name: String) -> Image? {
        let baseName = (name as NSString).deletingPathExtension
        #if canImport(UIKit)
        if let uiImage = UIImage(named: name) ?? UIImage(named: baseName) {
            return Image(uiImage: uiImage)
        }
        #elseif canImport(AppKit)
        if let nsImage = NSImage(named: name) ?? NSImage(named: baseName) {
            return Image(nsImage: nsImage)
        }
        #endif
        return nil
    }
}
