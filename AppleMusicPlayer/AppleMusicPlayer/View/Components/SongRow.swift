//
//  SongRow.swift
//  AppleMusicPlayer
//
//  Created by Pavlo Tereshchuk on 03.05.23.
//

import SwiftUI

/// A queue row showing a song's artwork, title and artist.
struct SongRow: View {

    // MARK: - Public properties

    /// The song to display.
    var song: Song

    // MARK: - Body

    var body: some View {
        HStack(alignment: .center) {
            Image(uiImage: song.image!)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                .padding(.vertical, 5)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(song.title)
                    .font(.body)
                    .foregroundColor(.primary)
                Text(song.artist)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
            .lineLimit(1)
            .padding(5)
            
            Spacer()
        }
    }
}

struct SongRow_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThickMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(LinearGradient(colors: [.white, .blue, .gray], startPoint: .top, endPoint: .bottomTrailing))
                }
            List {
                SongRow(song: Song(name: "Mermaids"))
                    .preferredColorScheme(.dark)
            }
        }
    }
}
