//
//  ContentView.swift
//  tabBar
//
//  Created by Pavlo Tereshchuk on 28.03.23.
//

import SwiftUI

/// The app's root view.
///
/// This is where the ``HomeViewModel`` is created and kept alive for the
/// lifetime of the app, so the song queue and playback state survive as views
/// come and go.
struct ContentView: View {

    // MARK: - Public properties

    @StateObject var vm = HomeViewModel(audioPlayer: AudioPlayer.getInstance())

    // MARK: - Body

    var body: some View {
        HomeView(vm: vm)
            .onAppear {
                UIButton.appearance().tintColor = .red
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView(vm: HomeViewModel(audioPlayer: AudioPlayer.getInstance()))
    }
}
