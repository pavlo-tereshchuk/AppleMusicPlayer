//
//  AudioPlayer.swift
//  tabBar
//
//  Created by Pavlo Tereshchuk on 07.04.23.
//

import Foundation
import AVFoundation
import SwiftUI

class AudioPlayer: NSObject, AVAudioPlayerDelegate {
    
    private var audioPlayer: AVAudioPlayer?
    private var finished = false
    static private var instance: AudioPlayer?
    
    static func getInstance() -> AudioPlayer {
        if instance == nil {
            instance = AudioPlayer()
        }
        
        return instance!
    }

    func prepareToPlay(_ song: Song) {
    do {
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try AVAudioSession.sharedInstance().setActive(true)
        // Initialize the audio player with the song file
        audioPlayer = try AVAudioPlayer(contentsOf: song.url, fileTypeHint: AVFileType.mp3.rawValue)
        
        // Set our class as delegate
        audioPlayer?.delegate = self
        
        // Play the song
        audioPlayer?.prepareToPlay()
        // Rewind the song to the beginning
        audioPlayer?.currentTime = 0
        
        // Song duration
        song.duration = getDuration()
        
    } catch {
        // If there was an error initializing the audio player, print the error
        print(error.localizedDescription)
    }
}
    
    func play() {
        if finished {
            finished = false
        }
        audioPlayer?.play()
    }
    
    func play(atTime: TimeInterval) {
        if finished {
            finished = false
        }
        audioPlayer?.play(atTime: atTime)
    }
    
    func pause() {
        audioPlayer?.pause()
    }
    
    func isPlaying() -> Bool? {
        return audioPlayer?.isPlaying
    }
    
    func isFinished() -> Bool {
        return self.finished
    }
    
    func setCurrentTime(_ time: TimeInterval) {
        audioPlayer?.currentTime = time
    }
    
    func getCurrentTime() -> TimeInterval? {
        return audioPlayer?.currentTime
    }
    
    func getDuration() -> TimeInterval {
        return Double(audioPlayer?.duration ?? 0)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        player.pause()
        player.currentTime = 0
        self.finished = true
        
    }
}
