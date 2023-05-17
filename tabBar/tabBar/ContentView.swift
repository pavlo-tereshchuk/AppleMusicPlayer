//
//  ContentView.swift
//  tabBar
//
//  Created by Pavlo Tereshchuk on 28.03.23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var vm = HomeViewModel(audioPlayer: AudioPlayer.getInstance())

    var body: some View {
        HomeView(vm: vm)
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView(vm: HomeViewModel(audioPlayer: AudioPlayer.getInstance()))
    }
}
