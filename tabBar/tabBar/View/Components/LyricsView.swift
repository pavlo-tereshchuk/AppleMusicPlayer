//
//  LyricsView.swift
//  tabBar
//
//  Created by Pavlo Tereshchuk on 15.05.23.
//

import SwiftUI

struct LyricsView: View {
    var lyrics: String?
    @Binding var scrollUp: Bool
    
    var body: some View {
        if let lyrics = lyrics {
            ScrollView {
                Text(lyrics)
                    .font(.title3)
                    .foregroundStyle(.ultraThickMaterial)
                    .opacity(0.65)
            }
            .scrollIndicators(.hidden)
            .simultaneousGesture(
                   DragGesture()
                    .onChanged({
                        if $0.predictedEndLocation.y > $0.location.y {
                            scrollUp = false
                        } else {
                            scrollUp = true
                        }
                       
                   }))
        } else {
            Text("no lyrics available")
                .foregroundStyle(.ultraThickMaterial)
                .opacity(0.65)
        }
    }
}

struct LyricsView_Previews: PreviewProvider {
    @State static var scrollUp = false
    static var previews: some View {
        LyricsView(lyrics: Song(name: "02 Champion").lyrics, scrollUp: $scrollUp)
            .preferredColorScheme(.dark)
    }
}
