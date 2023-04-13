//
//  Home.swift
//  tabBar
//
//  Created by Pavlo Tereshchuk on 28.03.23.
//

import SwiftUI

struct HomeView: View {
    @StateObject var vm = HomeViewModel()
    @State private var expandScheet = false
    @Namespace private var animation
    
    var body: some View {
        TabView {
            TabItem("Listen Now", "play.circle.fill")
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
                ExpandedSongView(expandScheet: $expandScheet, animation: animation)
                    .transition(.asymmetric(insertion: .identity, removal: .offset(y: -5)))
            }
        }
        .onAppear {
            vm.getSongsList()
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
                        MusicInfo(expandScheet: $expandScheet, animation: animation)
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
    var animation: Namespace.ID
    var body: some View {
        HStack(spacing: 0) {
            ZStack {
                if !expandScheet {
                    GeometryReader {
                        let size = $0.size
                        Image("Icon1")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                    }
                    .matchedGeometryEffect(id: "ICON1", in: animation)
                }
            }
            .frame(width: 45, height: 45)
            
            Text("Accordion")
                .fontWeight(.semibold)
                .lineLimit(1)
                .padding(15)
                
            
            Spacer(minLength: 20)
            
            Button {
                
            } label: {
                Image(systemName: "pause.fill")
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
