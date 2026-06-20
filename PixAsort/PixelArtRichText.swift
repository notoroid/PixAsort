//
//  PixelArtRichText.swift
//  PixAsort
//
//  Created by 能登 要 on 2026/06/20.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
import UniformTypeIdentifiers

/// アートワーク画像のピクセルを `NSTextTable` のセル背景色として並べ、
/// タイル状（ピクセルアート）の `NSAttributedString` を生成するユーティリティ。
/// iOS 27 以降で UIKit に追加された `NSTextTable` / `NSTextTableBlock` / `NSTextBlock` を使用する。
enum PixelArtRichText {
    /// 指定したアートワークから dimension×dimension のピクセルアートテーブルを生成する。
    /// - Parameters:
    ///   - name: バンドルリソースの画像名（例: "001.png"）。
    ///   - dimension: 1 辺のピクセル数（64 または 32）。
    ///   - totalSize: テーブル全体のおおよその 1 辺のポイント数。
    static func make(imageNamed name: String, dimension: Int, totalSize: CGFloat = 320) -> NSAttributedString? {
        guard dimension > 0,
              let colors = pixelColors(imageNamed: name, dimension: dimension) else {
            return nil
        }

        // 各セル（=1 ピクセル）の 1 辺のポイント数。
        let cellSize = totalSize / CGFloat(dimension)

        // テーブル本体。列数を固定し、最初の行のセル幅でレイアウトを決める。
        let table = NSTextTable()
        table.numberOfColumns = dimension
        table.layoutAlgorithm = .fixed
        table.collapsesBorders = true
        table.hidesEmptyCells = false

        let result = NSMutableAttributedString()
        // セルの文字は見えないようにし、行の高さはブロックの height で固定する。
        let cellFont = UIFont.systemFont(ofSize: 1)

        for row in 0..<dimension {
            for column in 0..<dimension {
                // 1 ピクセルぶんのセルブロックを作成し、背景色にピクセル色を設定する。
                let cell = NSTextTableBlock(
                    table: table,
                    startingRow: row, rowSpan: 1,
                    startingColumn: column, columnSpan: 1
                )
                cell.backgroundColor = colors[row][column]

                // セルを正方形のピクセルにする。余白・境界は 0 にして隙間なく並べる。
                cell.setContentWidth(cellSize, type: .absolute)
                cell.setValue(cellSize, type: .absolute, for: .height)
                cell.setWidth(0, type: .absolute, for: .padding)
                cell.setWidth(0, type: .absolute, for: .border)
                cell.setWidth(0, type: .absolute, for: .margin)

                // セルブロックを段落に割り当てる（1 セル = 1 段落）。
                let style = NSMutableParagraphStyle()
                style.textBlocks = [cell]

                let attributes: [NSAttributedString.Key: Any] = [
                    .paragraphStyle: style,
                    .font: cellFont,
                    .foregroundColor: UIColor.clear
                ]
                // 非改行スペース + 改行で段落（セル）を構成する。
                result.append(NSAttributedString(string: "\u{00A0}\n", attributes: attributes))
            }
        }

        return result
    }

    /// 生成したピクセルアートのリッチテキストをペーストボードにコピーする。
    /// セル背景色やテーブル構造を保持できるよう RTF として書き込み、
    /// 併せてプレーンテキストのフォールバックも設定する。
    static func copyToPasteboard(_ attributedString: NSAttributedString) {
        let range = NSRange(location: 0, length: attributedString.length)
        var item: [String: Any] = [:]

        if let rtf = try? attributedString.data(
            from: range,
            documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]
        ) {
            item[UTType.rtf.identifier] = rtf
        }
        // RTF に対応しない貼り付け先向けのフォールバック。
        item[UTType.utf8PlainText.identifier] = attributedString.string

        UIPasteboard.general.setItems([item])
    }

    /// 画像を dimension×dimension に描画し、各ピクセルの色を 2 次元配列で返す。
    /// 配列は [row][column]（row 0 が画像上端）。
    private static func pixelColors(imageNamed name: String, dimension: Int) -> [[UIColor]]? {
        let baseName = (name as NSString).deletingPathExtension
        guard let image = UIImage(named: name) ?? UIImage(named: baseName),
              let cgImage = image.cgImage else {
            return nil
        }

        let width = dimension
        let height = dimension
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        var data = [UInt8](repeating: 0, count: bytesPerRow * height)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: &data,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return nil
        }

        // ピクセルアートを正確にサンプリングするため補間を無効にする。
        context.interpolationQuality = .none
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        var rows: [[UIColor]] = []
        rows.reserveCapacity(height)
        for y in 0..<height {
            var rowColors: [UIColor] = []
            rowColors.reserveCapacity(width)
            for x in 0..<width {
                let offset = y * bytesPerRow + x * bytesPerPixel
                let alpha = CGFloat(data[offset + 3]) / 255
                // premultipliedLast のため、RGB を α で割って元の色に戻す。
                let color: UIColor
                if alpha > 0 {
                    let red = CGFloat(data[offset]) / 255 / alpha
                    let green = CGFloat(data[offset + 1]) / 255 / alpha
                    let blue = CGFloat(data[offset + 2]) / 255 / alpha
                    color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
                } else {
                    color = .clear
                }
                rowColors.append(color)
            }
            rows.append(rowColors)
        }
        return rows
    }
}

/// `NSAttributedString`（NSTextTable を含む）を表示するための UITextView ラッパー。
struct RichTextView: UIViewRepresentable {
    let attributedText: NSAttributedString

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = false
        textView.backgroundColor = .systemBackground
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = attributedText
    }
}
#endif
