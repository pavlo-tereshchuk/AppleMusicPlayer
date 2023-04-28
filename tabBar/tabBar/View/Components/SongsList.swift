//
//  SongsList.swift
//  tabBar
//
//  Created by Pavlo Tereshchuk on 28.04.23.
//

import SwiftUI

struct SongsList: View {
    @State var songs: [Song]
    var scrollTo: Song?
    @State private var listOffset: CGFloat = 0
    
    init(songs: [Song], scrollTo: Song? = nil) {
        self.songs = songs
        self.scrollTo = scrollTo
        self.listOffset = listOffset
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            VStack {
                List {
                    ForEach(songs) { song in
                        HStack(alignment: .bottom) {
                            Image(uiImage: song.image!)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text(song.title)
                                    .font(.body)
                                    .foregroundColor(.white)
                                Text(song.artist)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.ultraThickMaterial)
                                    .opacity(0.65)
                            }
                            .lineLimit(1)
                            .padding(5)
                            
                            Spacer()
                        }
                        .id(song.url)
                        .frame(maxWidth: .infinity)
                        .background(.clear)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)

                    }
                    .onMove(perform: moveRow)
                }
                .environment(\.editMode, .constant(.active))
                .scrollIndicators(.hidden)
                .scrollContentBackground(.hidden)
                .onAppear {
                    if let scrollTo = scrollTo {
                        proxy.scrollTo(scrollTo.url, anchor: .top)
                    }
                }
            }
        }
            
    }
    
    private func moveRow(source: IndexSet, destination: Int){
        songs.move(fromOffsets: source, toOffset: destination)
    }
}

struct SongsList_Previews: PreviewProvider {

    static var previews: some View {
        
        ZStack {
            
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThickMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(LinearGradient(colors: [.white, .blue, .gray], startPoint: .top, endPoint: .bottomTrailing))
                }
                .overlay(alignment: .top) {
                    SongsList(songs: [Song(name: "Mermaids"), Song(name: "Juice Jones"), Song(name: "Mermaids"), Song(name: "Juice Jones"), Song(name: "Mermaids"), Song(name: "Juice Jones"), Song(name: "Mermaids"), Song(name: "Juice Jones"), Song(name: "Mermaids"), Song(name: "Juice Jones"), Song(name: "Mermaids"), Song(name: "Juice Jones"), Song(name: "Mermaids"), Song(name: "Juice Jones"), Song(name: "Mermaids"), Song(name: "Daft_Punk_GLBTM"),
                                      Song(name: "Juice Jones"), Song(name: "Mermaids"), Song(name: "Juice Jones"), Song(name: "Mermaids"), Song(name: "Juice Jones"), Song(name: "Mermaids"), Song(name: "Juice Jones"), Song(name: "Mermaids"),
                                      Song(name: "Juice Jones")])
                    .frame(height: 400)
//                    .mask(LinearGradient(gradient: Gradient(colors: [.blue, .clear]), startPoint: .top, endPoint: .bottom))
                }
        }
        .ignoresSafeArea(.container, edges: .all)
    }
}
