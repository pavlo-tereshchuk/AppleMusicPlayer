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
    
    func start(_ song: Song) {
        do {
            // Initialize the audio player with the song file
            audioPlayer = try AVAudioPlayer(contentsOf: song.url)
            
            // Play the song
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            // Rewind the song to the beginning
            audioPlayer?.currentTime = 0
            
        } catch {
            // If there was an error initializing the audio player, print the error
            print(error.localizedDescription)
        }
    }
    
    func pause_play() {
        if let audioPlayer = audioPlayer {
            if audioPlayer.isPlaying {
                audioPlayer.pause()
            } else {
                audioPlayer.play()
            }
        }
    }
    
    func setCurrentTime(_ time: Double) {
        audioPlayer?.currentTime = time
    }
}
