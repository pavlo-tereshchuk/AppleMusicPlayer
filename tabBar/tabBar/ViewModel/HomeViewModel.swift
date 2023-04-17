//
//  HomeViewModel.swift
//  tabBar
//
//  Created by Pavlo Tereshchuk on 13.04.23.
//

import Foundation

class HomeViewModel: ObservableObject {
    @Published var songs: [Song] = [Song(name: "")]
    @Published var isLoaded = false
    @Published var currentSong = 0
    
    let audioPlayer = AudioPlayer()
    
    init() {
       getSongsList()
    }

    func getSongsList() -> Bool{
        if let bundlePath = Bundle.main.resourcePath {
            let fileManager = FileManager.default
            let mp3Files = try? fileManager.contentsOfDirectory(atPath: bundlePath).filter {
                $0.contains(".mp3")
            }
            
            if let mp3Files = mp3Files {
                self.songs = mp3Files.compactMap({Song(name: $0.split(separator: ".").map(String.init)[0])})
                isLoaded = true
                return true
            }
        } else {
            print("Could not retrieve bundle path.")
        }
        return false
    }
    
    func pressPlayPause() {
        
    }
}
