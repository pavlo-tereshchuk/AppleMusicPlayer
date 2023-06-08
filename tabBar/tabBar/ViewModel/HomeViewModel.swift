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
    @Published var isLoaded = false
    
//    Content
    @Published var songs: [Song] = [Song(name: "")]
    @Published var nextSongs: [Song] = []
    @Published var prevSongs: [Song] = []
    
    private let audioPlayer: AudioPlayer

//    Current song in Player
    @Published var currentSong = 0 {
        didSet {
            getNextPrevFromSongs()
        }
    }
    
    @Published var currentTime: TimeInterval = 0
    @Published var volume: Float = 0
    
//    MARK: UI
    @Published var minimizedImage: Bool = false
//    States for bottom buttons
    @Published var quoteButton: Bool = false {
        didSet {
            if quoteButton && listButton {
                listButton = false
            }
            
            if !quoteButton && !listButton {
                minimizedImage = false
            }
            
            if quoteButton && !listButton {
                minimizedImage = true
            }
        }
    }
    @Published var listButton: Bool = false {
        didSet {
            if quoteButton && listButton {
                quoteButton = false
            }
            
            if !quoteButton && !listButton {
                minimizedImage = false
            }
            
            if !quoteButton && listButton {
                minimizedImage = true
            }
        }
    }
    
//    SongList modes
    @Published var shuffleSongs = false
    @Published var repeatSongs = false
    @Published var infinitySongs = false
    
    //    Drop down menu buttons
    let dropDownMenuItems: KeyValuePairs<String, String> = [
        "Add to Library" : "plus",
        "Add to a Playlist..." : "text.badge.plus",
        "Play Next" : "text.insert",
        "Play Last" : "text.append",
        "Share Song..." : "square.and.arrow.up",
        "View Full Lyrics" : "quote.bubble",
        "Share Lyrics" : "arrow.up.square",
        "Show Album" : "music.note.list",
        "Create Station" : "badge.plus.radiowaves.right",
        "Love" : "heart",
        "Suggest Less Like This" : "hand.thumbsdown"
    ]
    
    
    
    init(audioPlayer: AudioPlayer) {
        self.audioPlayer = audioPlayer
        self.isLoaded = self.getSongsList()
        self.prepareToPlay(getCurrentSong())
        self.volume = getVolume()
        self.nextSongs = Array(songs.suffix(from: currentSong + 1))
    }
    
//    MARK: Player controls
    
    func playSong(song: Song) {
        let nextSong = {
            
            if let songNum = self.songs.firstIndex(where: {$0.id == song.id}) {
                self.currentSong = songNum
                self.prepareToPlay(self.getCurrentSong())
            }
        }
        
        if isPlaying() {
            nextSong()
            play()
        } else {
            nextSong()
        }
    }
    
    func playNext() {
        let nextSong = {
//          normal song change
            if !self.lastSong() {
                self.currentSong += 1
                self.prepareToPlay(self.getCurrentSong())
            } else
//          when a song is last in queue and infinity mode is turned on
            if self.lastSong() && self.repeatSongs {
                self.currentSong = 0
                self.prepareToPlay(self.getCurrentSong())
            } else
//          last song and no infinity mode
            if self.lastSong() && !self.repeatSongs {
                print(self.isFinished())
                if self.isFinished() {
                    self.play()
                    self.setCurrentTime(.zero)
                    self.pause()
                }
                return
            }
            
            if self.isFinished() {
                self.play()
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
        
        print(currentSong)
        
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
    
    func lastSong() -> Bool {
        return currentSong + 1 == songs.count
    }
    
//    MARK: Volume
    
    func getVolume() -> Float {
        return MPVolumeView.getVolume()
    }
    
    func setVolume(_ volume: Float) {
        MPVolumeView.setVolume(volume)
    }
    
//    MARK: Mutating Songs Array
    
    func getNextPrevFromSongs() {
        nextSongs = currentSong < songs.count ? Array(songs.suffix(from: currentSong + 1)) : []
        prevSongs = currentSong > 0 ? Array(songs.prefix(upTo: currentSong - 1)) : []
    }
    
    
}
