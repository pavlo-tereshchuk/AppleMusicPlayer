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
    var url: URL
    var image = UIImage()
    
    init(name: String) {
        self.fileName = name
        let filePath = Bundle.main.path(forResource: name, ofType: "mp3")
        self.url = URL(fileURLWithPath: filePath!)
        self.extractSongData()
    }
    
    func extractSongData(){
        let asset = AVAsset(url: url)
        asset.loadValuesAsynchronously(forKeys: ["commonMetadata"]) {
            var error: NSError?
                        let status = asset.statusOfValue(forKey: "commonMetadata", error: &error)

                        switch status {
                            case .loaded:
                                for i in asset.commonMetadata{
                                    if i.commonKey?.rawValue == "artwork"{
                                        let data = i.value as! Data
                                        self.image  = UIImage(data: data) ?? UIImage()
                                    }

                                    if i.commonKey?.rawValue == "title"{
                                        let data = i.value as! String
                                        self.title = data
                                    }
                                }
                            case .failed:
                                print("Failed to load metadata: \(error?.localizedDescription ?? "Unknown error")")
                            case .cancelled:
                                print("Loading metadata was cancelled.")
                            default:
                                break
                        }
        }

    }
}

