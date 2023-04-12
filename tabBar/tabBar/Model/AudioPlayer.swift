//
//  AudioPlayer.swift
//  tabBar
//
//  Created by Pavlo Tereshchuk on 07.04.23.
//

import Foundation
import AVFoundation
import SwiftUI

class AudioPlayer {
    var audioPlayer: AVAudioPlayer?
    
    
    func playSong(_ songName: String) {
        let filePath = Bundle.main.path(forResource: songName, ofType: "mp3")
        
        // Create a URL object from the file path
        let fileURL = URL(fileURLWithPath: filePath!)
        
        do {
            // Initialize the audio player with the song file
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            
            // Play the song
            audioPlayer?.play()
            
            // Rewind the song to the beginning
            audioPlayer?.currentTime = 0
            
        } catch {
            // If there was an error initializing the audio player, print the error
            print(error.localizedDescription)
        }
    }
}

class Song {
    let name: String
    let url: URL
    var image = UIImage()
    
    init(name: String) {
        self.name = name
        let filePath = Bundle.main.path(forResource: name, ofType: "mp3")
        self.url = URL(fileURLWithPath: filePath!)
        self.image = extractSongData()
    }
    
    func extractSongData() -> UIImage{
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let timestamp = CMTime(seconds: 5, preferredTimescale: 1)
        let imageRef = try? generator.copyCGImage(at: timestamp, actualTime: nil)
        let image = (imageRef == nil ? UIImage() : UIImage(cgImage: imageRef!))
        return image
    }
}

