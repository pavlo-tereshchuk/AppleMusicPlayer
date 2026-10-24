//
//  HomeViewModel.swift
//  AppleMusicPlayer
//
//  Created by Pavlo Tereshchuk on 13.04.23.
//

import Foundation
import AVFoundation
import MediaPlayer

/// The source of truth for the player's song queue, playback state and UI.
///
/// The view model owns the library — every MP3 bundled with the app — and
/// exposes the playback controls the views bind to. It forwards transport
/// commands to an ``AudioPlayer`` and reads system volume through
/// `MPVolumeView`, publishing both so SwiftUI can track them.
///
/// Playback position isn't observed automatically: `AVAudioPlayer` offers no
/// progress callbacks, so ``ExpandedSongView`` polls ``getCurrentTime()`` on a
/// timer and writes the result into ``currentTime``.
class HomeViewModel: ObservableObject {

    // MARK: - Public properties

    /// Whether the song library was read from the app bundle successfully.
    @Published var isLoaded = false

//    Content
    /// The full queue, in playback order.
    ///
    /// Reordering this array is how the queue list rearranges upcoming songs.
    @Published var songs: [Song] = [Song(name: "")]

    /// The songs queued after ``currentSong``, shown in the queue list.
    @Published var nextSongs: [Song] = []

    /// The songs played before ``currentSong``.
    @Published var prevSongs: [Song] = []

//    Current song in Player
    /// The index into ``songs`` of the track loaded in the player.
    ///
    /// Changing this refreshes ``nextSongs`` and ``prevSongs``, but doesn't
    /// load the new track — callers pair it with ``prepareToPlay(_:)``.
    @Published var currentSong = 0 {
        didSet {
            getNextPrevFromSongs()
        }
    }
    
    /// The playback position in seconds, refreshed by the expanded player's
    /// timer and written back when the user scrubs.
    @Published var currentTime: TimeInterval = 0

    /// The system output volume, from `0` to `1`.
    @Published var volume: Float = 0

    // MARK: UI
    /// Whether the artwork is shrunk to a thumbnail to make room for the
    /// lyrics or queue panel.
    ///
    /// Derived from ``quoteButton`` and ``listButton``; it's `true` whenever
    /// exactly one of them is on.
    @Published var minimizedImage: Bool = false

//    States for bottom buttons
    /// Whether the lyrics panel is showing.
    ///
    /// Turning this on dismisses the queue panel, since the two share the
    /// space freed up by the minimized artwork.
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
    /// Whether the queue panel is showing.
    ///
    /// Turning this on dismisses the lyrics panel.
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
    /// Whether the shuffle button is lit.
    ///
    /// - Note: Presentation only — the queue isn't shuffled yet.
    @Published var shuffleSongs = false

    /// Whether playback wraps around to the first song after the last one.
    @Published var repeatSongs = false

    /// Whether the infinity button is lit.
    ///
    /// - Note: Presentation only — autoplay isn't implemented yet.
    @Published var infinitySongs = false

    //    Drop down menu buttons
    /// Titles and SF Symbol names for the song's context menu, in display order.
    ///
    /// - Note: The entries are decorative; none of them perform an action yet.
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

    // MARK: - Private properties

    private let audioPlayer: AudioPlayer

    // MARK: - Init

    /// Loads the song library and cues up the first track, paused.
    ///
    /// - Parameter audioPlayer: The player to route transport commands to,
    ///   normally ``AudioPlayer/getInstance()``.
    init(audioPlayer: AudioPlayer) {
        self.audioPlayer = audioPlayer
        self.isLoaded = self.getSongsList()
        self.prepareToPlay(getCurrentSong())
        self.volume = getVolume()
        self.nextSongs = Array(songs.suffix(from: currentSong + 1))
    }
    
    // MARK: - Public methods

    // MARK: Player controls

    /// Jumps to a song in the queue.
    ///
    /// The track only starts automatically if something was already playing,
    /// matching Apple Music's behavior when you tap a row while paused.
    ///
    /// - Parameter song: A song in ``songs``. Songs outside the queue are
    ///   ignored.
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
    
    /// Advances to the next song in the queue.
    ///
    /// At the end of the queue the behavior depends on ``repeatSongs``: with
    /// repeat on, playback wraps to the first song; with it off, the last track
    /// is rewound and left paused. As with ``playSong(song:)``, playback only
    /// resumes if it was already underway.
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
    
    /// Steps back to the previous song, or does nothing at the start of the
    /// queue.
    ///
    /// The expanded player only calls this when playback is near the beginning
    /// of a track; later on, the back button restarts the current song instead.
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

    /// Builds ``songs`` from every MP3 found in the app bundle.
    ///
    /// The library is whatever ships inside the bundle, so adding music means
    /// dropping files into the `Songs` folder at build time.
    ///
    /// - Returns: `true` if the bundle could be read, `false` otherwise.
    func getSongsList() -> Bool{
        if let bundlePath = Bundle.main.resourcePath {
            let fileManager = FileManager.default
            let mp3Files = try? fileManager.contentsOfDirectory(atPath: bundlePath).filter {
                $0.hasSuffix(".mp3")
            }
            
            if let mp3Files = mp3Files {
                self.songs = mp3Files.compactMap({Song(name: ($0 as NSString).deletingPathExtension)})
                return true
            }
        } else {
            print("Could not retrieve bundle path.")
        }
        return false
    }

    /// The song currently loaded in the player.
    func getCurrentSong() -> Song {
        return songs[currentSong]
    }

    /// Loads a song into the player without starting it.
    ///
    /// - Parameter song: The song to cue up.
    func prepareToPlay(_ song: Song) {
        audioPlayer.prepareToPlay(song)
    }

    /// Starts or resumes playback.
    func play() {
        audioPlayer.play()
    }

    /// Schedules playback to begin at a point on the audio device's clock.
    ///
    /// - Parameter atTime: The device-clock time at which to start.
    func playAtTime(atTime: TimeInterval) {
        audioPlayer.play(atTime: atTime)
    }

    /// Toggles between playing and paused.
    func pause_play() {
        if isPlaying() {
            pause()
        } else {
            play()
        }
    }
    
    /// Pauses playback, keeping the current position.
    func pause() {
        audioPlayer.pause()
    }

    /// Seeks the current track.
    ///
    /// - Parameter time: The offset from the start of the track, in seconds.
    func setCurrentTime(_ time: TimeInterval) {
        audioPlayer.setCurrentTime(time)
    }

    /// The live playback position in seconds, or `nil` if nothing is loaded.
    func getCurrentTime() -> TimeInterval? {
       return audioPlayer.getCurrentTime()
    }

    /// Whether audio is playing right now.
    func isPlaying() -> Bool {
        return audioPlayer.isPlaying() ?? false
    }

    /// Whether the current track has reached its end and is awaiting the next
    /// one.
    func isFinished() -> Bool {
        return audioPlayer.isFinished()
    }

    /// The length of the current track in seconds.
    func getDuration() -> TimeInterval {
        return audioPlayer.getDuration()
    }

    /// Whether ``currentSong`` is the last entry in the queue.
    func lastSong() -> Bool {
        return currentSong + 1 == songs.count
    }
    
    // MARK: Volume
    
    /// The current system output volume, from `0` to `1`.
    func getVolume() -> Float {
        return MPVolumeView.getVolume()
    }

    /// Sets the system output volume.
    ///
    /// - Parameter volume: The target level, from `0` to `1`.
    func setVolume(_ volume: Float) {
        MPVolumeView.setVolume(volume)
    }

    // MARK: Mutating Songs Array

    /// Recomputes ``nextSongs`` and ``prevSongs`` from ``currentSong``.
    ///
    /// Call this after reordering ``songs`` so the queue list reflects the new
    /// order.
    func getNextPrevFromSongs() {
        nextSongs = currentSong < songs.count ? Array(songs.suffix(from: currentSong + 1)) : []
        prevSongs = currentSong > 0 ? Array(songs.prefix(upTo: currentSong - 1)) : []
    }
    
    
}
