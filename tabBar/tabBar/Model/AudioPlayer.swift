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
    let fileName: String
    var title: String = ""
    var artist: String = ""
    var url: URL
    var image: UIImage? = UIImage(named: "placeholder")! {
        didSet {
            if image == nil {
                image = UIImage(named: "placeholder")!
            }
        }
    }
    
    init(name: String) {
        self.fileName = name
        let filePath = Bundle.main.path(forResource: name, ofType: "mp3")
        self.url = URL(fileURLWithPath: filePath!)
        self.extractSongData()
    }
    
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
                 
        }

    }
}

