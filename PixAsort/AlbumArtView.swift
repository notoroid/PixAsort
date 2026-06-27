//
//  AlbumArtView.swift
//  PixAsort
//
//  Created by 能登 要 on 2026/06/20.
//

import SwiftUI
import UniformTypeIdentifiers

/// 単一の `AlbumArt` を表示するビュー。
/// アートワーク（通常 / コンパクト）をセグメントで切り替えられる。
struct AlbumArtView: View {
    let albumArt: AlbumArt

    /// 表示するアートワークの種類。
    private enum ArtworkKind: String, CaseIterable, Identifiable {
        case full = "Artwork"
        case compact = "Compact"

        var id: Self { self }
    }

    @State private var selectedArtwork: ArtworkKind = .compact

    /// 👍 アニメーションの表示状態。
    @State private var showThumbsUp = false

#if canImport(UIKit)
    /// 生成したピクセルアートのリッチテキスト。
    @State private var richText: NSAttributedString?
    /// リッチテキスト表示シートの表示状態。
    @State private var showRichText = false
#endif

    /// 現在選択中のアートワークのファイル名。
    private var artworkName: String {
        switch selectedArtwork {
        case .full: albumArt.artwork
        case .compact: albumArt.compactArtwork
        }
    }

    /// 選択中アートワークのピクセル数（1 辺）。Artwork は 64、Compact は 32。
    private var pixelDimension: Int {
        switch selectedArtwork {
        case .full: 64
        case .compact: 32
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            // アートワークを通常 / コンパクトで切り替えるセグメント。
            Picker("Artwork", selection: $selectedArtwork) {
                ForEach(ArtworkKind.allCases) { kind in
                    Text(kind.rawValue).tag(kind)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            // 選択中のアートワークを表示する。
            // ピクセルアートを鮮明に表示するため `.interpolation(.none)` を付加する。
            Group {
                if let image = Self.loadImage(named: artworkName) {
                    image
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                } else {
                    ContentUnavailableView("画像が見つかりません", systemImage: "photo")
                }
            }
            .frame(height: 340)

            // メタデータ表示。
            VStack(alignment: .leading, spacing: 12) {
                Text(albumArt.title)
                    .font(.title2)
                    .fontWeight(.bold)

                LabeledContent("Album", value: albumArt.album)
                LabeledContent("Genre", value: albumArt.genre)
                LabeledContent("Release Year", value: String(albumArt.year))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)

            // 機能ボタン。
            HStack(spacing: 12) {
                Button("RichTextに変換") {
                    convertToRichText()
                }
                .buttonStyle(.borderedProminent)

                Button {
                    copyImage()
                } label: {
                    Label("画像をコピー", systemImage: "photo.on.rectangle")
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .overlay {
            // アクション後にポップする 👍 アニメーション。
            if showThumbsUp {
                Text("👍")
                    .font(.system(size: 100))
                    .transition(.scale(scale: 0.3).combined(with: .opacity))
            }
        }
#if canImport(UIKit)
        .sheet(isPresented: $showRichText) {
            if let richText {
                NavigationStack {
                    ScrollView {
                        RichTextView(attributedText: richText)
                            .frame(minHeight: 400)
                            .padding()
                    }
                    .navigationTitle("Pixel Art")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Done") { showRichText = false }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            // 生成したピクセルアートをペーストボードへコピーする。
                            Button {
                                PixelArtRichText.copyToPasteboard(richText)
                            } label: {
                                Label("Copy", systemImage: "doc.on.doc")
                            }
                        }
                    }
                }
            }
        }
#endif
    }

    /// RichText 変換アクション。
    /// 選択中アートワークのピクセルを NSTextTable のセル背景色として並べた
    /// ピクセルアートのリッチテキストを生成する。
    private func convertToRichText() {
#if canImport(UIKit)
        if let generated = PixelArtRichText.make(imageNamed: artworkName, dimension: pixelDimension) {
            richText = generated
            showRichText = true
        }
#endif

        popThumbsUp()
    }

    /// 選択中アートワークの画像をペーストボードにコピーする。
    /// 元 PNG のバイト列をそのままコピーするため、オリジナルのピクセルサイズ
    /// （Artwork: 64×64 / Compact: 32×32）が保たれる。
    /// 成功時に 👍 アニメーションを表示する。
    private func copyImage() {
#if canImport(UIKit)
        let nsName = artworkName as NSString
        let resource = nsName.deletingPathExtension
        let ext = nsName.pathExtension.isEmpty ? "png" : nsName.pathExtension

        if let url = Bundle.main.url(forResource: resource, withExtension: ext),
           let data = try? Data(contentsOf: url) {
            // 元ファイルのバイト列をそのまま PNG として書き込む（再エンコード・拡大なし）。
            UIPasteboard.general.setData(data, forPasteboardType: UTType.png.identifier)
            popThumbsUp()
        } else if let uiImage = UIImage(named: resource) {
            // フォールバック（バンドルにファイルが見つからない場合）。
            UIPasteboard.general.image = uiImage
            popThumbsUp()
        }
#elseif canImport(AppKit)
        let nsName = artworkName as NSString
        let resource = nsName.deletingPathExtension
        let ext = nsName.pathExtension.isEmpty ? "png" : nsName.pathExtension

        let pasteboard = NSPasteboard.general
        if let url = Bundle.main.url(forResource: resource, withExtension: ext),
           let data = try? Data(contentsOf: url) {
            // 元ファイルのバイト列をそのまま PNG として書き込む（再エンコード・拡大なし）。
            pasteboard.clearContents()
            pasteboard.setData(data, forType: NSPasteboard.PasteboardType(UTType.png.identifier))
            popThumbsUp()
        } else if let nsImage = NSImage(named: resource) {
            // フォールバック（バンドルにファイルが見つからない場合）。
            pasteboard.clearContents()
            pasteboard.writeObjects([nsImage])
            popThumbsUp()
        }
#endif
    }

    /// 👍 をポップ表示し、しばらくして自動的に消す。
    private func popThumbsUp() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.5)) {
            showThumbsUp = true
        }
        Task {
            try? await Task.sleep(for: .seconds(0.8))
            withAnimation(.easeOut(duration: 0.3)) {
                showThumbsUp = false
            }
        }
    }

    /// バンドルリソースからファイル名で画像を読み込む。
    private static func loadImage(named name: String) -> Image? {
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

#Preview {
    AlbumArtView(
        albumArt: AlbumArt(
            title: "Live Your Life",
            genre: "Pop",
            artwork: "001.png",
            compactArtwork: "001-compact.png",
            year: 2012,
            artist: "Yuna",
            album: "Yuna"
        )
    )
}
