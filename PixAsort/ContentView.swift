//
//  ContentView.swift
//  PixAsort
//
//  Created by 能登 要 on 2026/06/20.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    /// App Intents と共有するナビゲーション状態（検索テキスト・選択中の AlbumArt）。
    @State private var navigation = AppNavigation.shared

    var body: some View {
        NavigationSplitView {
            // 検索テキスト・選択を共有モデル経由で扱い、App Intents からも駆動できるようにする。
            AlbumArtListView(
                searchText: navigation.searchText,
                selection: $navigation.selectedAlbumArtID
            )
            .navigationTitle("Album Art")
            .searchable(text: $navigation.searchText, prompt: "Title, Album, Artist, Genre, Year")
        } detail: {
            AlbumArtDetailColumn(selectedID: navigation.selectedAlbumArtID)
        }
    }
}

/// AlbumArt の一覧を表示するビュー。
/// 検索テキストに応じた動的 `@Query` でフェッチするため、1000 件以上でも
/// `List` の遅延描画と相まって効率良く表示できる。
private struct AlbumArtListView: View {
    @Query private var albumArts: [AlbumArt]

    /// 選択中の AlbumArt の `uniqueID`。`.photos.openAsset` からも更新される。
    @Binding var selection: UUID?

    /// compactArtwork サムネイルのサイズ。
    /// normalSize で 47pt、Dynamic Type のフォントサイズに連動して拡大縮小する。
    @ScaledMetric private var thumbnailSize: CGFloat = 47

    init(searchText: String, selection: Binding<UUID?>) {
        _selection = selection

        // 検索テキストに一致する AlbumArt のみをフェッチする predicate を構築する。
        // title / album / artist / genre / year（メタデータ）を検索対象とする。
        // 非表示（isHidden）の AlbumArt は常に一覧から除外する。
        let predicate: Predicate<AlbumArt>
        if searchText.isEmpty {
            predicate = #Predicate<AlbumArt> { art in
                art.isHidden == false
            }
        } else {
            // 数値として解釈できない場合は year には一致しないようにする。
            let yearValue = Int(searchText) ?? Int.min
            predicate = #Predicate<AlbumArt> { art in
                art.isHidden == false
                    && (art.title.localizedStandardContains(searchText)
                        || art.album.localizedStandardContains(searchText)
                        || art.artist.localizedStandardContains(searchText)
                        || art.genre.localizedStandardContains(searchText)
                        || art.year == yearValue)
            }
        }
        _albumArts = Query(filter: predicate, sort: \AlbumArt.title)
    }

    var body: some View {
        // List + ForEach は行を遅延描画するため、件数が多くても全件表示できる。
        // selection を `uniqueID` にタグ付けし、App Intents からの選択にも対応する。
        List(selection: $selection) {
            ForEach(albumArts) { albumArt in
                row(for: albumArt)
                    .tag(albumArt.uniqueID)
            }
        }
    }

    /// 一覧の 1 行分の表示。
    private func row(for albumArt: AlbumArt) -> some View {
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

            Spacer(minLength: 0)

            // お気に入りのときだけ星を表示する。
            if albumArt.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                    .accessibilityLabel("Favorite")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// 選択中の AlbumArt を `uniqueID` から解決して詳細を表示する詳細カラム。
private struct AlbumArtDetailColumn: View {
    let selectedID: UUID?

    @Query private var matches: [AlbumArt]

    init(selectedID: UUID?) {
        self.selectedID = selectedID
        // selectedID が nil の場合は何もフェッチしない predicate にする。
        let predicate: Predicate<AlbumArt>
        if let selectedID {
            predicate = #Predicate<AlbumArt> { $0.uniqueID == selectedID }
        } else {
            predicate = #Predicate<AlbumArt> { _ in false }
        }
        _matches = Query(filter: predicate)
    }

    var body: some View {
        if let albumArt = matches.first {
            AlbumArtView(albumArt: albumArt)
        } else {
            Text("Select an album")
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: AlbumArt.self, inMemory: true)
}
