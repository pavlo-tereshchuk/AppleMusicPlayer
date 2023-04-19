//
//  ContentView.swift
//  tabBar
//
//  Created by Pavlo Tereshchuk on 28.03.23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var vm = HomeViewModel()
    let timer = Timer.publish(every: 0.5, on: .main, in: .common)
        .autoconnect()

    var body: some View {
        HomeView(vm: vm)
            .onReceive(timer) { _ in
//                vm.currentTime = vm.getCurrentTime()
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView(vm: HomeViewModel())
    }
}
