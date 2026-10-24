//
//  Song.swift
//  AppleMusicPlayer
//
//  Created by Pavlo Tereshchuk on 17.04.23.
//

import Foundation
import SwiftUI
import AVFoundation


/// A playable track loaded from an MP3 file bundled with the app.
///
/// Creating a song reads the file's embedded metadata — title, artist, artwork
/// and lyrics — and derives the colors used to tint the player's background.
/// All of that work happens synchronously in ``init(name:)``, so songs are
/// intended to be created once and reused.
class Song: Identifiable {

    // MARK: - Public properties

    /// A stable identity for use in SwiftUI lists and `matchedGeometryEffect`.
    let id = UUID()

    /// The bundle resource name of the MP3 file, without its extension.
    let fileName: String

    /// The track title from the file's metadata, or an empty string if absent.
    var title: String = ""

    /// The performing artist from the file's metadata, or an empty string if absent.
    var artist: String = ""

    /// The length of the track in seconds.
    ///
    /// Metadata alone doesn't report duration, so this stays `0` until
    /// ``AudioPlayer/prepareToPlay(_:)`` loads the file and fills it in.
    var duration: Double = 0

    /// The embedded lyrics, or `nil` when the file carries none.
    var lyrics: String?

    /// The on-disk location of the MP3 file inside the app bundle.
    var url: URL

    /// The album artwork, falling back to the bundled placeholder image.
    ///
    /// Assigning `nil` restores the placeholder, so callers can always render
    /// this without unwrapping.
    var image: UIImage? = UIImage(named: "placeholder")! {
        didSet {
            if image == nil {
                image = UIImage(named: "placeholder")!
            }
        }
    }
    /// The single dominant color of the artwork, used to tint active controls.
    var averageColor = Color(UIColor.darkGray)

    /// The average color of each artwork quadrant, used as gradient stops
    /// behind the expanded player.
    var background: [Color] = [.gray, .white]

    // MARK: - Init

    /// Creates a song from an MP3 resource in the app bundle.
    ///
    /// - Parameter name: The resource name of the MP3 file, without its
    ///   extension.
    ///
    /// - Important: This traps if no matching resource exists in the bundle.
    init(name: String) {
        self.fileName = name
        let filePath = Bundle.main.path(forResource: name, ofType: "mp3")
        self.url = URL(fileURLWithPath: filePath!)
        self.extractSongData()
        self.background = self.image!.getAverageColors()
        self.averageColor = Color(self.image!.averageColor ?? UIColor.darkGray)
    }

    // MARK: - Public methods

    /// Reads title, artist, artwork and lyrics from the file's common metadata.
    ///
    /// Any field the file doesn't provide keeps its default value.
    func extractSongData(){
        let asset = AVAsset(url: url)
    
        for i in asset.commonMetadata{
            if i.commonKey == .commonKeyArtwork{
                let data = i.value as! Data
                self.image  = UIImage(data: data)
            }

            if i.commonKey == .commonKeyTitle{
                let data = i.value as! String
                self.title = data
            }
            
            if i.commonKey == .commonKeyArtist{
                let data = i.value as! String
                self.artist = data
            }
            
            self.lyrics = asset.lyrics
            
        }
    }
    
}
