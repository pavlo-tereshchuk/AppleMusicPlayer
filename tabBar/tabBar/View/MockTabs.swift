//
//  MockTabs.swift
//  tabBar
//
//  Created by Pavlo Tereshchuk on 24.10.26.
//

import SwiftUI

/// Mock content for the tabs surrounding the player.
///
/// Only the player is implemented; these screens exist to reproduce Apple
/// Music's chrome. Everything on them is drawn from the real bundled library
/// in ``HomeViewModel/songs`` — artwork, titles, artists and the gradients
/// derived from each cover — so no fixture data is needed. Section names and
/// category tiles are the only hard-coded strings.

// MARK: - Shared pieces

/// A square cover tile with the song's title and artist underneath.
struct ArtworkCard: View {

    // MARK: - Public properties

    var song: Song

    /// The cover's edge length; the caption sits below it.
    var side: CGFloat = 165

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(uiImage: song.image!)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: side, height: side)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            Text(song.title)
                .font(.footnote)
            Text(song.artist)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .lineLimit(1)
        .frame(width: side, alignment: .leading)
    }
}

/// A titled horizontal row of ``ArtworkCard``s, as used across Apple Music's
/// browsing screens.
struct Shelf: View {

    // MARK: - Public properties

    var title: String
    var songs: [Song]
    var side: CGFloat = 165

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title2.bold())
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 15) {
                    ForEach(songs) { song in
                        ArtworkCard(song: song, side: side)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

/// A full-width hero card tinted with the artwork's own gradient.
///
/// - Parameters:
///   - eyebrow: The small upper-case line above the title, e.g. `"STATION"`.
struct FeaturedCard: View {

    // MARK: - Public properties

    var eyebrow: String
    var song: Song

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(eyebrow)
                .font(.caption.bold())
                .foregroundStyle(.secondary)

            ZStack(alignment: .bottomLeading) {
                LinearGradient(colors: song.background, startPoint: .top, endPoint: .bottomTrailing)

                HStack(spacing: 12) {
                    Image(uiImage: song.image!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 70, height: 70)
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(song.title)
                            .font(.headline)
                        Text(song.artist)
                            .font(.subheadline)
                            .opacity(0.8)
                    }
                    .lineLimit(1)
                }
                .foregroundStyle(.white)
                .shadow(radius: 3)
                .padding(15)
            }
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .padding(.horizontal, 20)
    }
}

/// A grid of flat colored tiles standing in for Apple Music's category links.
struct CategoryGrid: View {

    // MARK: - Public properties

    var title: String

    /// Tile labels, paired with the color each tile is filled with.
    var categories: [(String, Color)]

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title2.bold())

            LazyVGrid(columns: [GridItem(), GridItem()], spacing: 12) {
                ForEach(categories, id: \.0) { name, color in
                    Text(name)
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 60, alignment: .bottomLeading)
                        .padding(10)
                        .background(color, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Tabs

/// The "Home" tab, mirroring Apple Music's Listen Now.
struct HomeTab: View {

    // MARK: - Public properties

    @ObservedObject var vm: HomeViewModel

    // MARK: - Body

    var body: some View {
        MockTabScroll(title: "Listen Now", vm: vm) { songs in
            FeaturedCard(eyebrow: "TOP PICKS", song: songs[0])
            Shelf(title: "Recently Played", songs: songs)
            Shelf(title: "Made For You", songs: songs.reversed())
        }
    }
}

/// The "Browse" tab: new music and genre links.
struct BrowseTab: View {

    // MARK: - Public properties

    @ObservedObject var vm: HomeViewModel

    // MARK: - Body

    var body: some View {
        MockTabScroll(title: "Browse", vm: vm) { songs in
            Shelf(title: "New Releases", songs: songs)
            Shelf(title: "Hits by Decade", songs: songs.shuffled(), side: 130)
            CategoryGrid(title: "Browse by Category", categories: [
                ("Hip-Hop", .orange), ("Pop", .pink),
                ("Dance", .purple), ("R&B", .indigo)
            ])
        }
    }
}

/// The "Radio" tab: a featured station plus shows and genre stations.
struct RadioTab: View {

    // MARK: - Public properties

    @ObservedObject var vm: HomeViewModel

    // MARK: - Body

    var body: some View {
        MockTabScroll(title: "Radio", vm: vm) { songs in
            FeaturedCard(eyebrow: "LIVE RADIO", song: songs[songs.count - 1])
            Shelf(title: "Hosted Shows", songs: songs, side: 130)
            CategoryGrid(title: "Stations by Genre", categories: [
                ("Today's Hits", .red), ("Chill", .teal),
                ("Classics", .brown), ("Workout", .green)
            ])
        }
    }
}

/// The "Music" tab, mirroring Apple Music's Library.
///
/// The song list is the one live part of these mocks: tapping a row hands the
/// song to ``HomeViewModel/playSong(song:)``, same as the player's queue.
struct MusicTab: View {

    // MARK: - Public properties

    @ObservedObject var vm: HomeViewModel

    // MARK: - Private properties

    /// The library's category rows, as label and SF Symbol pairs.
    private let categories = [
        ("Playlists", "music.note.list"), ("Artists", "music.mic"),
        ("Albums", "square.stack"), ("Songs", "music.note"),
        ("Downloaded", "arrow.down.circle")
    ]

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoaded {
                    List {
                        ForEach(categories, id: \.0) { name, icon in
                            Label(name, systemImage: icon)
                                .font(.title3)
                                .foregroundStyle(.primary)
                                .listRowSeparator(.hidden, edges: .top)
                        }

                        Section("Recently Added") {
                            ForEach(vm.songs) { song in
                                SongRow(song: song)
                                    .onTapGesture { vm.playSong(song: song) }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Library")
        }
    }
}

/// The "Search" tab: a live filter over the bundled library.
struct SearchTab: View {

    // MARK: - Public properties

    @ObservedObject var vm: HomeViewModel

    // MARK: - Private properties

    @State private var query = ""

    /// The library filtered by title or artist; empty while nothing is typed.
    private var results: [Song] {
        guard !query.isEmpty else { return [] }
        return vm.songs.filter {
            $0.title.localizedCaseInsensitiveContains(query)
            || $0.artist.localizedCaseInsensitiveContains(query)
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                if query.isEmpty {
                    CategoryGrid(title: "Browse Categories", categories: [
                        ("Charts", .red), ("New Music", .mint),
                        ("Decades", .cyan), ("Live Events", .yellow)
                    ])
                    .padding(.top, 10)
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(results) { song in
                            SongRow(song: song)
                                .padding(.horizontal, 20)
                                .contentShape(Rectangle())
                                .onTapGesture { vm.playSong(song: song) }
                        }
                    }
                }
            }
            .navigationTitle("Search")
            .searchable(text: $query, prompt: "Artists, Songs, Lyrics, and More")
        }
    }
}

// MARK: - Scaffolding

/// A scrolling mock screen with a large title, built once the library is read.
///
/// The library is loaded asynchronously, so the content closure only runs once
/// ``HomeViewModel/isLoaded`` is set — before that ``HomeViewModel/songs``
/// holds a single empty placeholder.
struct MockTabScroll<Content: View>: View {

    // MARK: - Public properties

    var title: String
    @ObservedObject var vm: HomeViewModel

    /// The screen's sections, given the loaded library.
    @ViewBuilder var content: ([Song]) -> Content

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                if vm.isLoaded {
                    VStack(alignment: .leading, spacing: 30) {
                        content(vm.songs)
                    }
                    .padding(.vertical, 10)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle(title)
        }
    }
}
