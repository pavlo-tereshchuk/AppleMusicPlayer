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
    @State private var pressedRowID = UUID()
    @State private var shuffleButton = false
    @State private var repeatButton = false
    @State private var infinityButton = false
    
    
    init(songs: Binding<[Song]>, currentSong: Song) {
        self._songs = songs
        self.currentSong = currentSong
//        let currIndex = songs.firstIndex(where: {$0.id == currentSong.id})
//        
//        if let currIndex  = currIndex {
//            self.nextSongs = Array( songs.wrappedValue.suffix(from: currIndex + 1))
//        } else {
//            self.nextSongs = songs.wrappedValue
//        }
    }
    
    var body: some View {
            ZStack(alignment: .top) {
                List {
                    ForEach(songs) { song in
                        SongRow(song: song)
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
                .padding(.top, 30)
                .listStyle(InsetGroupedListStyle())
                .environment(\.editMode, .constant(.active))
                .scrollIndicators(.hidden)
                .scrollContentBackground(.hidden)
                .onAppear {
                    UIScrollView.appearance().bounces = false
                }
                .onDisappear {
                    UIScrollView.appearance().bounces = true
                }
                
                
                HStack(spacing: 15) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("In queue")
                            .font(.body)
                            .foregroundColor(.white)
                        Text("Autoplay similar music")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.ultraThickMaterial)
                            .opacity(0.65)
                    }
                    
                    Spacer()
                    HStack(spacing: 15) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.05)) {
                                shuffleButton.toggle()
                            }
                        } label: {
                            customButtonLabel(imageName: "shuffle", toggleButton: shuffleButton, paddingEdges: .vertical, paddingLength: 1, toggleColor: Color(currentSong.image!.averageColor ?? UIColor.darkGray))
                                .scaleEffect(1.3)
                            
                        }
                        
                        Button {
                            withAnimation(.easeInOut(duration: 0.05)) {
                                repeatButton.toggle()
                            }
                        } label: {
                            customButtonLabel(imageName: "repeat", toggleButton: repeatButton, paddingEdges: .vertical, paddingLength: 1, toggleColor: Color(currentSong.image!.averageColor ?? UIColor.darkGray))
                                .scaleEffect(1.3)
                        }
                        
                        Button {
                            withAnimation(.easeInOut(duration: 0.05)) {
                                infinityButton.toggle()
                            }
                        } label: {
                            customButtonLabel(imageName: "infinity", toggleButton: infinityButton, paddingEdges: .vertical, paddingLength: 1, toggleColor: Color(currentSong.image!.averageColor ?? UIColor.darkGray))
                                .scaleEffect(1.3)
                        }
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .padding(.horizontal)
            }
    }
    
    @ViewBuilder
    func customButtonLabel(imageName: String, toggleButton: Bool, paddingEdges: Edge.Set = .all, paddingLength: CGFloat = 0, toggleColor: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(.white)
                .foregroundStyle(.ultraThickMaterial)
                .scaleEffect(toggleButton ? 1 : 0.6)
                .opacity(toggleButton ? 0.65 : 0)
            
            Image(systemName: imageName)
                .foregroundColor(toggleButton ? toggleColor : Color.white)
                .foregroundStyle(toggleButton ? Material.regularMaterial : .ultraThickMaterial)
                .opacity(toggleButton ? 1 : 0.65)
                .padding(paddingEdges, paddingLength)
                .padding(.vertical, 4)
                .padding(.horizontal, 2)
                .fontWeight(.semibold)
        }
        .frame(width: 30, height: 30)
        .scaleEffect(0.8)
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
                        .fill(LinearGradient(colors: [.green, .blue, .gray], startPoint: .top, endPoint: .bottomTrailing))
                }
                .overlay(alignment: .top) {
                    SongsList(songs: $songs, currentSong: curSong)
                    .frame(height: 400)
                    .border(.black)
//                    .mask(LinearGradient(gradient: Gradient(colors: [.blue, .clear]), startPoint: .top, endPoint: .bottom))
                    .padding(.top, 30)
                }
        }
        .ignoresSafeArea(.container, edges: .all)
    }
}
