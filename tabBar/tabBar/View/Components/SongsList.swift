//
//  SongsList.swift
//  tabBar
//
//  Created by Pavlo Tereshchuk on 28.04.23.
//

import SwiftUI

struct SongsList: View {
    @Binding var songs: [Song]
    var currentSong: Song
    private var prevSongs: [Song] = []
    var nextSongs: [Song] = []
    var scrollTo: Song?
    @State private var pressedRowID = UUID()
    
    
    init(songs: Binding<[Song]>, currentSong: Song, scrollTo: Song? = nil) {
        self._songs = songs
        self.currentSong = currentSong
        self.scrollTo = scrollTo
        let currIndex = songs.firstIndex(where: {$0.id == currentSong.id})
        
        if let currIndex  = currIndex {
            self.nextSongs = Array( songs.wrappedValue.suffix(from: currIndex + 1))
        } else {
            self.nextSongs = songs.wrappedValue
        }
    }
    
    var body: some View {
//        Text("\(songs.firstIndex(where: {$0.id == currentSong.id}) ?? 0)")
        ScrollViewReader { proxy in
                List {
                    ForEach(nextSongs) { song in
                        SongRow(song: song)
                        .id(song.url)
                        .frame(maxWidth: .infinity)
                        .listRowInsets(EdgeInsets())
                        .padding(.bottom, 10)
                        .background(.clear)
                        .onTapGesture {
                            print("TAP")
                        }
                        .onLongPressGesture(minimumDuration: 1) {
                            self.pressedRowID = song.id
                            print("Long")
                        }

                    }
                    .onMove(perform: moveRow)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
                .listStyle(InsetGroupedListStyle())
                .environment(\.editMode, .constant(.active))
                .scrollIndicators(.hidden)
                .scrollContentBackground(.hidden)
                .onAppear {
                    UIScrollView.appearance().bounces = false
                    if let scrollTo = scrollTo {
                        proxy.scrollTo(scrollTo.url, anchor: .top)
                    }
                }
                .onDisappear {
                    UIScrollView.appearance().bounces = true
                }
                .border(.white)

        }
            
    }
    
    private func moveRow(source: IndexSet, destination: Int){
        songs.move(fromOffsets: source, toOffset: destination)
    }
}

struct SongsList_Previews: PreviewProvider {
    
    static let curSong = Song(name: "Juice Jones")
    @State static var songs = [Song(name: "Mermaids"), curSong,
                               Song(name: "Daft_Punk_GLBTM")]

    static var previews: some View {
        ZStack {
            
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThickMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(LinearGradient(colors: [.white, .blue, .gray], startPoint: .top, endPoint: .bottomTrailing))
                }
                .overlay(alignment: .top) {
                    SongsList(songs: $songs, currentSong: curSong)
                    .frame(height: 400)
                    .border(.black)
//                    .mask(LinearGradient(gradient: Gradient(colors: [.blue, .clear]), startPoint: .top, endPoint: .bottom))
                }
        }
        .ignoresSafeArea(.container, edges: .all)
    }
}
