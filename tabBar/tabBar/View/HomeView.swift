//
//  Home.swift
//  tabBar
//
//  Created by Pavlo Tereshchuk on 28.03.23.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var vm: HomeViewModel
    @State private var expandScheet = false
    @State var isPlaying: Bool = false
    @Namespace private var animation
    
    
    var body: some View {
        TabView {
            TabItem("Home", "play.circle.fill")
            TabItem("Browse", "square.grid.2x2.fill")
            TabItem("Radio", "dot.radiowaves.left.and.right")
            TabItem("Music", "play.square.fill")
            TabItem("Search", "magnifyingglass")
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
    
    @ViewBuilder
    func TabItem(_ title: String, _ icon: String) -> some View {
        ScrollView(.vertical, showsIndicators: false){
            Text(title)
                .padding(.top, 200)
        }
        .tabItem {
                Image(systemName: icon)
                Text(title)
        }
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarBackground(.ultraThickMaterial, for: .tabBar)
        .toolbar(expandScheet ? .hidden : .visible, for: .tabBar)
    }
}

struct MusicInfo: View {
    @Binding var expandScheet: Bool
    @Binding var isPlaying: Bool
    @ObservedObject var vm: HomeViewModel
    var animation: Namespace.ID
    
    
    var body: some View {
        let song = vm.getCurrentSong()

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
