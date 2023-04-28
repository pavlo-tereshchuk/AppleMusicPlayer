//
//  Song.swift
//  tabBar
//
//  Created by Pavlo Tereshchuk on 17.04.23.
//

import Foundation
import SwiftUI
import AVFoundation



class Song: Identifiable {
    let id = UUID()
    let fileName: String
    var title: String = ""
    var artist: String = ""
    var duration: Double = 0
    var lyrics: String = ""
    var url: URL
    var image: UIImage? = UIImage(named: "placeholder")! {
        didSet {
            if image == nil {
                image = UIImage(named: "placeholder")!
            }
        }
    }
    
    init(name: String) {
        self.fileName = name
        let filePath = Bundle.main.path(forResource: name, ofType: "mp3")
        self.url = URL(fileURLWithPath: filePath!)
        self.extractSongData()
        print("LYRICS: \(lyrics)")
    }
    
    func extractSongData(){
        let asset = AVAsset(url: url)
    
        for i in asset.commonMetadata{
            if i.commonKey == .commonKeyArtwork{
                let data = i.value as! Data
                self.image  = UIImage(data: data)
            }

            if i.commonKey == .commonKeyTitle{
                let data = i.value as! String
                self.title = data
            }
            
            if i.commonKey == .commonKeyArtist{
                let data = i.value as! String
                self.artist = data
            }
            
            if i.commonKey == .id3MetadataKeyOriginalLyricist{
                let data = i.value as! String
                self.lyrics = data
            }
        }
    }
    
}
