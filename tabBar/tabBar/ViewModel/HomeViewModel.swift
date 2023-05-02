//
//  HomeViewModel.swift
//  tabBar
//
//  Created by Pavlo Tereshchuk on 13.04.23.
//

import Foundation
import AVFoundation
import MediaPlayer

class HomeViewModel: ObservableObject {
    @Published var songs: [Song] = [Song(name: "")]
    @Published var isLoaded = false
    @Published var currentSong = 0
    
    //    Drop down menu buttons
    let dropDownMenuItems = [
        "Add to Library" : "plus",
        "Add to a Playlist..." : "text.badge.plus",
        "Play Next" : "text.insert",
        "Play Last" : "text.append",
        "Share Song..." : "square.and.arrow.up",
        "View Full Lyrics" : "text.quote",
        "Share Lyrics" : "",
        "Show Album" : "music.note.list",
        "Create Station" : "badge.plus.radiowaves.right",
        "Love" : "heart",
        "Suggest Less Like This" : "hand.thumbsdown"
    ]
    
    
    let audioPlayer = AudioPlayer.getInstance()
    
    init() {
        self.isLoaded = self.getSongsList()
        self.prepareToPlay(getCurrentSong())
    }
    
//    MARK: Player controls
    func playNext() {
        let nextSong = {
            if self.currentSong + 1 < self.songs.count {
                self.currentSong += 1
                self.prepareToPlay(self.getCurrentSong())

                if self.isFinished() {
                    self.play()
                }
            }
        }
        
        if isPlaying() {
            nextSong()
            play()
        } else {
            nextSong()
        }
    }
    
    func playPrev() {
        let prevSong = {
            if self.currentSong > 0 {
                self.currentSong -= 1
                self.prepareToPlay(self.getCurrentSong())
            }
        }
        
        if isPlaying() {
            prevSong()
            play()
        } else {
            prevSong()
        }
    }

    func getSongsList() -> Bool{
        if let bundlePath = Bundle.main.resourcePath {
            let fileManager = FileManager.default
            let mp3Files = try? fileManager.contentsOfDirectory(atPath: bundlePath).filter {
                $0.contains(".mp3")
            }
            
            if let mp3Files = mp3Files {
                self.songs = mp3Files.compactMap({Song(name: $0.split(separator: ".").map(String.init)[0])})
                return true
            }
        } else {
            print("Could not retrieve bundle path.")
        }
        return false
    }

    func getCurrentSong() -> Song {
        return songs[currentSong]
    }
    
    func prepareToPlay(_ song: Song) {
        audioPlayer.prepareToPlay(song)
    }
    
    func play() {
        audioPlayer.play()
    }
    
    func playAtTime(atTime: TimeInterval) {
        audioPlayer.play(atTime: atTime)
    }
    
    func pause_play() {
        if isPlaying() {
            pause()
        } else {
            play()
        }
    }
    
    func pause() {
        audioPlayer.pause()
    }
    
    func setCurrentTime(_ time: TimeInterval) {
        audioPlayer.setCurrentTime(time)
    }
    
    func getCurrentTime() -> TimeInterval? {
       return audioPlayer.getCurrentTime()
    }
    
    func isPlaying() -> Bool {
        return audioPlayer.isPlaying() ?? false
    }
    
    func isFinished() -> Bool {
        return audioPlayer.isFinished()
    }
     
    func getDuration() -> TimeInterval {
        return audioPlayer.getDuration()
    }
    
//    MARK: Volume
    
    func getVolume() -> Float {
        return MPVolumeView.getVolume()
    }
    
    func setVolume(_ volume: Float) {
        MPVolumeView.setVolume(volume)
    }
    
}
