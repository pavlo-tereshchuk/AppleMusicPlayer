//
//  Extensions.swift
//  tabBar
//
//  Created by Pavlo Tereshchuk on 19.04.23.
//

import Foundation
import SwiftUI
import MediaPlayer

extension TimeInterval {
    var minuteSecond: String {
        String(format:"%d:%02d", minute, second)
    }
    
    var minute: Int {
        Int((self/60).truncatingRemainder(dividingBy: 60))
    }
    var second: Int {
        Int(truncatingRemainder(dividingBy: 60))
    }
}

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }
}

//Update system volume
extension MPVolumeView {
    
    static func setVolume(_ volume: Float) {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true)
            let volumeView = MPVolumeView()
            if let slider = volumeView.subviews.first as? UISlider {
                slider.value = volume
            }
        } catch {
            print("Error setting audio session active: \(error.localizedDescription)")
        }
    }

    static func getVolume() -> Float {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true)
            let volume = audioSession.outputVolume
            return volume
        } catch {
            print("Error setting audio session active: \(error.localizedDescription)")
            return 0.0
        }
    }
}
