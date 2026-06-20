//
//  ContentView.swift
//  PixAsort
//
//  Created by 能登 要 on 2026/06/20.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    /// メタデータ検索用のテキスト。
    @State private var searchText = ""

    var body: some View {
        NavigationSplitView {
            // 検索テキストを子ビューに渡し、SwiftData 側で絞り込む。
            AlbumArtListView(searchText: searchText)
                .navigationTitle("Album Art")
                .searchable(text: $searchText, prompt: "Title, Album, Artist, Genre, Year")
        } detail: {
            Text("Select an album")
        }
    }
}

/// AlbumArt の一覧を表示するビュー。
/// 検索テキストに応じた動的 `@Query` でフェッチするため、1000 件以上でも
/// `List` の遅延描画と相まって効率良く表示できる。
private struct AlbumArtListView: View {
    @Query private var albumArts: [AlbumArt]

    /// compactArtwork サムネイルのサイズ。
    /// normalSize で 47pt、Dynamic Type のフォントサイズに連動して拡大縮小する。
    @ScaledMetric private var thumbnailSize: CGFloat = 47

    init(searchText: String) {
        // 検索テキストに一致する AlbumArt のみをフェッチする predicate を構築する。
        // title / album / artist / genre / year（メタデータ）を検索対象とする。
        let predicate: Predicate<AlbumArt>?
        if searchText.isEmpty {
            predicate = nil
        } else {
            // 数値として解釈できない場合は year には一致しないようにする。
            let yearValue = Int(searchText) ?? Int.min
            predicate = #Predicate<AlbumArt> { art in
                art.title.localizedStandardContains(searchText)
                    || art.album.localizedStandardContains(searchText)
                    || art.artist.localizedStandardContains(searchText)
                    || art.genre.localizedStandardContains(searchText)
                    || art.year == yearValue
            }
        }
        _albumArts = Query(filter: predicate, sort: \AlbumArt.title)
    }

    var body: some View {
        // List + ForEach は行を遅延描画するため、件数が多くても全件表示できる。
        List(albumArts) { albumArt in
            NavigationLink {
                AlbumArtView(albumArt: albumArt)
            } label: {
                HStack(spacing: 12) {
                    // compactArtwork のサムネイル。
                    // normalSize で 47pt、フォントサイズ（Dynamic Type）に連動する。
                    ArtworkImage(name: albumArt.compactArtwork)
                        .scaledToFit()
                        .frame(width: thumbnailSize, height: thumbnailSize)
                        .clipShape(RoundedRectangle(cornerRadius: 6))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(albumArt.title)
                            .font(.headline)
                        Text("\(albumArt.artist) • \(albumArt.album)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("\(albumArt.genre) • \(String(albumArt.year))")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: AlbumArt.self, inMemory: true)
}
