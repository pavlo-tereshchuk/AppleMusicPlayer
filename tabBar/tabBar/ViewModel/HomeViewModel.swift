//
//  HomeViewModel.swift
//  tabBar
//
//  Created by Pavlo Tereshchuk on 13.04.23.
//

import Foundation

class HomeViewModel: ObservableObject {
    var songs: [Song] = .init()
    
    let audioPlayer = AudioPlayer()
    let song = Song(name: "song")

    func getSongsList() {
        if let bundlePath = Bundle.main.resourcePath {
            let fileManager = FileManager.default
            let mp3Files = try? fileManager.contentsOfDirectory(atPath: bundlePath).filter {
                $0.contains(".mp3")
            }
            print(mp3Files)
        } else {
            print("Could not retrieve bundle path.")
        }
    }
}
