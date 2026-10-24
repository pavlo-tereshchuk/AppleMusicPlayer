//
//  AudioPlayer.swift
//  AppleMusicPlayer
//
//  Created by Pavlo Tereshchuk on 07.04.23.
//

import Foundation
import AVFoundation
import SwiftUI

/// Plays a single song at a time on top of `AVAudioPlayer`.
///
/// Call ``prepareToPlay(_:)`` to load a song, then drive playback with
/// ``play()``, ``pause()`` and ``setCurrentTime(_:)``. Because the underlying
/// player is replaced on every load, loading a new song discards the previous
/// one's playback state.
///
/// The player tracks end-of-playback itself: once a track runs to completion
/// ``isFinished()`` returns `true` until playback is resumed, which lets the
/// view model advance the queue.
class AudioPlayer: NSObject, AVAudioPlayerDelegate {

    // MARK: - Private properties

    private var audioPlayer: AVAudioPlayer?
    private var finished = false
    static private var instance: AudioPlayer?

    // MARK: - Public methods

    /// The process-wide player instance, created on first use.
    ///
    /// Audio output is a single shared resource, so the whole app plays
    /// through one player rather than creating its own.
    static func getInstance() -> AudioPlayer {
        if instance == nil {
            instance = AudioPlayer()
        }
        
        return instance!
    }

    /// Loads a song, rewinds it to the start and leaves it paused.
    ///
    /// This also activates the shared audio session for playback and writes the
    /// decoded length back to the song's ``Song/duration``, which metadata
    /// alone can't supply. Errors are logged rather than thrown, so a song that
    /// fails to load simply won't play.
    ///
    /// - Parameter song: The song to load into the player.
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
    
    /// Starts or resumes playback from the current position.
    ///
    /// Clears the finished flag, so a track that had run to completion is
    /// considered playable again.
    func play() {
        if finished {
            finished = false
        }
        audioPlayer?.play()
    }

    /// Starts playback at a specific point on the audio device's timeline.
    ///
    /// - Parameter atTime: A time in the ``getDeviceCurrentTime``-style
    ///   device clock at which playback should begin, used to schedule
    ///   playback slightly in the future.
    func play(atTime: TimeInterval) {
        if finished {
            finished = false
        }
        audioPlayer?.play(atTime: atTime)
    }

    /// Pauses playback, keeping the current position.
    func pause() {
        audioPlayer?.pause()
    }

    /// Whether audio is currently coming out of the player.
    ///
    /// - Returns: `nil` when no song has been loaded yet.
    func isPlaying() -> Bool? {
        return audioPlayer?.isPlaying
    }

    /// Whether the loaded track has played all the way to its end.
    ///
    /// Stays `true` until playback is restarted, giving the view model a chance
    /// to advance to the next song.
    func isFinished() -> Bool {
        return self.finished
    }

    /// Seeks to a position in the loaded track.
    ///
    /// - Parameter time: The offset from the start of the track, in seconds.
    func setCurrentTime(_ time: TimeInterval) {
        audioPlayer?.currentTime = time
    }

    /// The current playback position in seconds.
    ///
    /// - Returns: `nil` when no song has been loaded yet.
    func getCurrentTime() -> TimeInterval? {
        return audioPlayer?.currentTime
    }

    /// The length of the loaded track in seconds, or `0` if nothing is loaded.
    func getDuration() -> TimeInterval {
        return Double(audioPlayer?.duration ?? 0)
    }

    /// Records that the track reached its end and rewinds it to the start.
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        player.pause()
        player.currentTime = 0
        self.finished = true
        
    }
    
    /// Ramps the player's own output level over time.
    ///
    /// This is independent of system volume, which the UI adjusts through
    /// ``HomeViewModel/setVolume(_:)``.
    ///
    /// - Parameters:
    ///   - volume: The target level, from `0` (silent) to `1` (full).
    ///   - fadeDuration: How long the ramp should take, in seconds.
    func setVolume(_ volume: Float, fadeDuration: TimeInterval) {
        audioPlayer?.setVolume(volume, fadeDuration: fadeDuration)
    }
}
