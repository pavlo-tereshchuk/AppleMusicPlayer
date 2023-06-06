//
//  SongsList.swift
//  tabBar
//
//  Created by Pavlo Tereshchuk on 28.04.23.
//

import SwiftUI

struct SongsList: View {
    @State var expandScheet: Bool
    @ObservedObject var vm: HomeViewModel
    @State private var pressedRowID = UUID()
    @State private var animateContent = false
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            ZStack(alignment: .top) {
                sectionQueue()
                    .padding(.horizontal, 25)
                if !vm.nextSongs.isEmpty {
                    List {
                        ForEach(vm.nextSongs) { song in
                            SongRow(song: song)
                                .frame(maxWidth: .infinity)
                                .listRowInsets(EdgeInsets())
                                .padding(.horizontal, 25)
                                .background(.clear)
                                .onTapGesture {
                                    vm.playSong(song: song)
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
                    .padding(.top, 60)
                    .padding(.horizontal, 5)
                    .listStyle(PlainListStyle())
                    .environment(\.editMode, .constant(.active))
                    .scrollContentBackground(.hidden)
                    .foregroundColor(.clear)
                    .onAppear {
                        UIScrollView.appearance().bounces = false
                    }
                    .onDisappear {
                        UIScrollView.appearance().bounces = true
                    }
                } else {
                    Rectangle()
                        .fill(.clear)
                }
            }
            //        in order to not trigger the ExpandedView gesture for folding
            .gesture(DragGesture(coordinateSpace: .global))
            .opacity(animateContent && expandScheet ? 1 : 0)
            .offset(y: animateContent && expandScheet ? 0 : size.height)
            .animation(.easeInOut(duration: 0.1), value: expandScheet)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.3)) {
                    animateContent = true
                }
            }
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
    
    @ViewBuilder
    func sectionHistory() -> some View {
        HStack {
            Text("History")
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Spacer()
            
            Button {
                
            } label: {
                Text("Clear")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.ultraThickMaterial)
                    .opacity(0.65)
            }
        }
        .frame(height: 60)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
    }
    
    @ViewBuilder
    func sectionQueue() -> some View {
        let avgColor = vm.getCurrentSong().averageColor
        HStack(spacing: 15) {
            VStack(alignment: .leading, spacing: 5) {
                Text("In queue")
                    .font(.body)
                    .fontWeight(.bold)
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
                        vm.shuffleSongs.toggle()
                    }
                } label: {
                    customButtonLabel(imageName: "shuffle", toggleButton: vm.shuffleSongs, paddingEdges: .vertical, paddingLength: 1, toggleColor: avgColor)
                        .scaleEffect(1.3)

                }

                Button {
                    withAnimation(.easeInOut(duration: 0.05)) {
                        vm.repeatSongs.toggle()
                    }
                } label: {
                    customButtonLabel(imageName: "repeat", toggleButton: vm.repeatSongs, paddingEdges: .vertical, paddingLength: 1, toggleColor: avgColor)
                        .scaleEffect(1.3)
                }

                Button {
                    withAnimation(.easeInOut(duration: 0.05)) {
                        vm.infinitySongs.toggle()
                    }
                } label: {
                    customButtonLabel(imageName: "infinity", toggleButton: vm.infinitySongs, paddingEdges: .vertical, paddingLength: 1, toggleColor: avgColor)
                        .scaleEffect(1.3)
                }
            }
            .padding(.vertical)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 60)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
    }
    
    private func moveRow(source: IndexSet, destination: Int){
        let offset = vm.currentSong + 1
        var newSource = IndexSet()
        source.forEach { value in
            newSource.insert(value + offset)
        }
        vm.songs.move(fromOffsets: newSource, toOffset: destination + offset)
        vm.getNextPrevFromSongs()
    }
}

struct SongsList_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack {
            
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThickMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(LinearGradient(colors: [.green, .blue, .gray], startPoint: .top, endPoint: .bottomTrailing))
                }
                .overlay(alignment: .top) {
                    SongsList(expandScheet: true, vm: HomeViewModel(audioPlayer: AudioPlayer.getInstance()))
                    .frame(height: 400)
                    .border(.black)
//                    .mask(
//                        LinearGradient(gradient: Gradient(colors: [Color.black, Color.black.opacity(0)]), startPoint: .top, endPoint: .bottom)
//                    )
//                    .mask(LinearGradient(gradient: Gradient(colors: [Color.black, Color.clear, Color.clear, Color.clear]), startPoint: .top, endPoint: .bottom))
                    .padding(.top, 30)
                }
        }
        .ignoresSafeArea(.container, edges: .all)
    }
}
