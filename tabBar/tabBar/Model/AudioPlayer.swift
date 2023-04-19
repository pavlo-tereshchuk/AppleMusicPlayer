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
    
    private var audioPlayer: AVAudioPlayer?
    static private var instance: AudioPlayer?
    
    static func getInstance() -> AudioPlayer {
        if instance == nil {
            instance = AudioPlayer()
        }
        
        return instance!
    }

    func prepareToPlay(_ song: Song) {
    do {
        // Initialize the audio player with the song file
        audioPlayer = try AVAudioPlayer(contentsOf: song.url)
        
        // Play the song
        audioPlayer?.prepareToPlay()
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
    
    func isPlaying() -> Bool? {
        return audioPlayer?.isPlaying
    }
    
    func setCurrentTime(_ time: Double) {
        audioPlayer?.currentTime = time
    }
    
    func getCurrentTime() -> TimeInterval {
        return audioPlayer?.currentTime ?? TimeInterval(0)
    }
    
    func getDuration() -> Double {
        return Double(audioPlayer?.duration ?? 0)
    }
}
