//
//  LyricsView.swift
//  tabBar
//
//  Created by Pavlo Tereshchuk on 15.05.23.
//

import SwiftUI

struct LyricsView: View {
    @State var expandScheet: Bool
    var lyrics: String?
    
    @State private var animateContent = false

    
    var body: some View {
        GeometryReader {
            let size = $0.size
            Group {
                if let lyrics = lyrics {
                    ScrollView {
                        Text(lyrics)
                            .font(.title3)
                            .foregroundStyle(.ultraThickMaterial)
                            .opacity(0.65)
                    }
                    .scrollIndicators(.hidden)
//        in order not to trigger the ExpandedView gesture for folding
                    .gesture(DragGesture(coordinateSpace: .global))
                    
                } else {
                    Text("no lyrics available")
                        .foregroundStyle(.ultraThickMaterial)
                        .opacity(0.65)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .opacity(animateContent && expandScheet ? 1 : 0)
            .offset(y: animateContent && expandScheet ? 0 : size.height)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.3)) {
                    animateContent = true
                }
            }
            .onDisappear {
                withAnimation(.easeInOut(duration: 0.3)) {
                    animateContent = false
                }
            }
        }
    }
}

struct LyricsView_Previews: PreviewProvider {
//    @State static var scrollUp = false
    static var previews: some View {
        LyricsView(expandScheet: true, lyrics: Song(name: "02 Champion").lyrics)
            .preferredColorScheme(.dark)
    }
}
