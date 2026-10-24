//
//  Home.swift
//  tabBar
//
//  Created by Pavlo Tereshchuk on 28.03.23.
//

import SwiftUI

/// The app's main screen: a tab bar with the mini player pinned above it.
///
/// Tapping the mini player presents ``ExpandedSongView`` as an overlay. Both
/// views draw from a shared `Namespace`, so the artwork and background
/// animate between the two with `matchedGeometryEffect` instead of being
/// cross-faded.
struct HomeView: View {

    // MARK: - Public properties

    @ObservedObject var vm: HomeViewModel

    /// A view-local mirror of the player's play/pause state, kept in sync by
    /// the expanded player's timer so both players animate together.
    @State var isPlaying: Bool = false

    // MARK: - Private properties

    /// Whether the full-screen now-playing view is presented.
    @State private var expandScheet = false

    /// The geometry namespace shared with ``ExpandedSongView``.
    @Namespace private var animation

    // MARK: - Body

    var body: some View {
        TabView {
            TabItem("Home", "play.circle.fill") { HomeTab(vm: vm) }
            TabItem("Browse", "square.grid.2x2.fill") { BrowseTab(vm: vm) }
            TabItem("Radio", "dot.radiowaves.left.and.right") { RadioTab(vm: vm) }
            TabItem("Music", "play.square.fill") { MusicTab(vm: vm) }
            TabItem("Search", "magnifyingglass") { SearchTab(vm: vm) }
        }
        .tint(.red)
        .safeAreaInset(edge: .bottom) {
            CustomPlayerView()
        }
        .overlay {
            if expandScheet {
                ExpandedSongView(expandScheet: $expandScheet, isPlaying: $isPlaying, vm: vm, animation: animation)
                    .transition(.asymmetric(insertion: .identity, removal: .offset(y: -5)))
            }
        }
    }
    
    // MARK: - Public methods

    /// The mini player bar that sits above the tab bar.
    ///
    /// While the expanded view is up, the bar's material is replaced with a
    /// clear rectangle so the shared background can animate upward without
    /// leaving a duplicate behind.
    @ViewBuilder
    func CustomPlayerView() -> some View {
        ZStack {
            if expandScheet {
                Rectangle()
                    .fill(.clear)
            } else {
                Rectangle()
                    .fill(.ultraThickMaterial)
                    .overlay {
                        MusicInfo(expandScheet: $expandScheet, isPlaying: $isPlaying, vm: vm, animation: animation)
                    }
                    .matchedGeometryEffect(id: "bigView", in: animation)
            }
            
            
                
        }
        .frame(height: 70)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(.gray.opacity(0.3))
                .frame(height: 0.5)
        }
         .offset(y: -49)
    }
    
    /// A tab carrying the chrome shared by every tab: its label, the tab bar's
    /// material, and hiding the bar while the expanded player is up.
    ///
    /// Only the player is implemented; the tabs themselves show the mock
    /// content in `MockTabs.swift`.
    ///
    /// - Parameters:
    ///   - title: The tab's label.
    ///   - icon: The SF Symbol name for the tab's icon.
    ///   - content: The tab's screen.
    @ViewBuilder
    func TabItem<Content: View>(_ title: String, _ icon: String, @ViewBuilder content: () -> Content) -> some View {
        content()
        .tabItem {
                Image(systemName: icon)
                Text(title)
        }
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarBackground(.ultraThickMaterial, for: .tabBar)
        .toolbar(expandScheet ? .hidden : .visible, for: .tabBar)
    }
}

/// The compact now-playing row: artwork, title, play/pause and skip.
///
/// The same view is rendered twice — once inside the mini player bar and once,
/// hidden, at the top of ``ExpandedSongView`` — so the two layouts share
/// identical geometry while the transition is in flight.
struct MusicInfo: View {

    // MARK: - Public properties

    /// Set to `true` when the row is tapped, presenting the expanded player.
    @Binding var expandScheet: Bool

    @Binding var isPlaying: Bool
    @ObservedObject var vm: HomeViewModel

    /// The geometry namespace shared with ``ExpandedSongView``.
    var animation: Namespace.ID

    // MARK: - Body

    var body: some View {
        let song = vm.songs[vm.currentSong]

        HStack(spacing: 0) {
            ZStack {
                if !expandScheet {
                    GeometryReader {
                        let size = $0.size
                        
                        Image(uiImage: song.image!)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: size.width, height: size.height)
                                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
   
                    }
                    .matchedGeometryEffect(id: "ICON1", in: animation)
                }
            }
            .frame(width: 45, height: 45)
            
            if vm.isLoaded {
                Text(song.title)
                    .lineLimit(1)
                    .padding(15)
            }
                
            
            Spacer(minLength: 20)
            
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isPlaying.toggle()
                }
                vm.pause_play()
            } label: {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
            }
            .padding(.horizontal, 15)
            
            Button {
                vm.playNext()
            } label: {
                Image(systemName: "forward.fill")
            }
        }
        .foregroundColor(.primary)
        .padding(.horizontal, 15)
        .frame(height: 70)
        .contentShape(Rectangle())
        .onAppear{
            isPlaying = vm.isPlaying()
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3), {expandScheet = true})
        }
    }
}



struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
