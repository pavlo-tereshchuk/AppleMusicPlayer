//
//  ExpandedView.swift
//  tabBar
//
//  Created by Pavlo Tereshchuk on 31.03.23.
//

import SwiftUI
import MediaPlayer


struct ExpandedSongView: View {
    @Binding var expandScheet: Bool
    @Binding var isPlaying: Bool
    @Binding var isFinished: Bool
    @ObservedObject var vm: HomeViewModel
    var animation: Namespace.ID
    @State private var animateContent: Bool = false
    @State private var minimizedImage: Bool = false
//    States for bottom buttons
    @State private var quoteButton: Bool = false {
        didSet {
            if quoteButton && listButton {
                listButton = false
            }
            
            if !quoteButton && !listButton {
                withAnimation(.easeInOut(duration: 0.3)) {
                    minimizedImage = false
                }
            }
            
            if quoteButton && !listButton {
                withAnimation(.easeInOut(duration: 0.3)) {
                    minimizedImage = true
                }
            }
        }
    }
    @State private var listButton: Bool = false {
        didSet {
            if quoteButton && listButton {
                quoteButton = false
            }
            
            if !quoteButton && !listButton {
                withAnimation(.easeInOut(duration: 0.3)) {
                    minimizedImage = false
                }
            }
            
            if !quoteButton && listButton {
                withAnimation(.easeInOut(duration: 0.3)) {
                    minimizedImage = true
                }
            }
        }
    }
    @State private var offsetY: CGFloat = 0
    @State private var currentTime: TimeInterval = 0
    @State private var hiddenSystemVolumeSlider: UISlider!

    
    let timer = Timer.publish(every: 0.25, on: .main, in: .common)
        .autoconnect()

    
    var body: some View {
        GeometryReader {
            let size = $0.size
            let safeArea = $0.safeAreaInsets
            let song = vm.songs[vm.currentSong]
            
            ZStack {
                RoundedRectangle(cornerRadius: animateContent ? deviceCornerRadius : 0, style: .continuous)
                    .fill(.ultraThickMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: animateContent ? deviceCornerRadius : 0, style: .continuous)
                            .fill(LinearGradient(colors: song.background, startPoint: .topLeading, endPoint: .bottomTrailing))
                            .opacity(animateContent ? 1:0.5)
                    }
                
                    .overlay(alignment: .top) {
                        MusicInfo(expandScheet: $expandScheet, isPlaying: $isPlaying, vm: vm, animation: animation)
                            .allowsHitTesting(false)
                            .opacity(animateContent ? 0:1)
                    }
                    .matchedGeometryEffect(id: "bigView", in: animation)
                    

                let spacing = size.height * 0.04
                
                VStack(spacing: spacing) {
                    Capsule()
                        .foregroundStyle(.ultraThickMaterial)
                        .frame(width: 40, height: 5)
                        .opacity(animateContent ? 0.65 : 0)
                        .offset(y: animateContent ? 0 : size.height)

                    VStack(spacing: spacing) {
                        
                        SongImageAndHeaderShareView(size)
                            .frame(height: minimizedImage ? (size.height/2.03 + size.height/7) : size.height/2.075)
                        
//                        else {
//                            SongsList(songs: $vm.songs, currentSong: song)
//                                .frame(height: size.height/2)
//                                .border(.white)
//                        }
                        
                        PlayerView(size)
                    }
                }
                .padding(.top, safeArea.top + (safeArea.bottom == 0 ? 10 : 0))
                .padding(.bottom, safeArea.bottom == 0 ? 10 : safeArea.bottom)
                .padding(.horizontal, 25)
                .clipped()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .ignoresSafeArea(.container, edges: .all)
            .contentShape(Rectangle())
            .offset(y: offsetY)
            .gesture (
                DragGesture()
                    .onChanged({value in
                        let translationY = value.translation.height
                        offsetY = (translationY > 0 ? translationY : 0)
                    })
                    .onEnded({value in
                        if offsetY > size.height * 0.4 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                expandScheet = false
                                animateContent = false
                            }
                        } else {
                            offsetY = .zero
                        }
                    })
            )
            .environment(\.colorScheme, .light)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.35)) {
                animateContent = true
                vm.setVolume(vm.getVolume())
            }
        }
        .onReceive(timer) { _ in
            self.isFinished = vm.isFinished()
            if !isFinished {
                self.currentTime = vm.getCurrentTime() ?? self.currentTime
            } else {
                self.vm.playNext()
            }
            
            self.isPlaying = self.vm.isPlaying()
            vm.volume = vm.getVolume()
        }
    }
    
    @ViewBuilder
    func PlayerView(_ size: CGSize) -> some View{
        let song = vm.songs[vm.currentSong]
        let spacing = size.height * 0.04
        VStack {
            
            
            
            if (!minimizedImage) {
                VStack(spacing: 20) {
                    SongHeaderAndShareView(song.title, artist: song.artist)
                        .matchedGeometryEffect(id: "SongHeaderAndShareView", in: animation)
                    
                   SongStatus(spacing: spacing, status: $currentTime.onChange({vm.setCurrentTime($0)}), duration: song.duration)
                    
                    
                }
                .frame(height: size.height/7)
            }
            

            //Play controls
            
            GeometryReader {
                let size = $0.size

                HStack(alignment: .center, spacing: size.width * 0.18) {
                    ControlButton {
                        if (currentTime < 5) {
                            vm.playPrev()
                        } else {
                            vm.setCurrentTime(0)
                        }
                    } content: {
                        Image(systemName: "backward.fill")
                            .font(size.height < 100 ? .title2 : .title)
                    }

                    ControlButton {
//                        isPlaying.toggle()
                        vm.pause_play()
                    } content: {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(size.height < 100 ? .largeTitle : .system(size: 40))
                            .animation(.easeInOut(duration: 0.3), value: isPlaying)
                    }



                    ControlButton {
                        vm.playNext()
                    } content: {
                        Image(systemName: "forward.fill")
                            .font(size.height < 100 ? .title2 : .title)
                    }

                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.bottom, 10)



            }
            .frame(maxHeight: .infinity)

            //Volume + Bottom buttons
            
            VStack {
                
                VolumeStatus(spacing: 15, volume: $vm.volume.onChange({vm.setVolume($0)}))
                
                HStack(alignment: .top, spacing: size.width * 0.18) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.05)) {
                            quoteButton.toggle()
                        }
                    } label: {
                        customButtonLabel(imageName: quoteButton ? "quote.bubble.fill" : "quote.bubble", toggleButton: quoteButton, toggleColor: song.averageColor)
                            
                    }
                    .scaleEffect(1.3)
                    
                    
                    VStack(spacing: 6) {
                        Button {
                            
                        } label: {
                            Image(systemName: "airpods")
                                .scaleEffect(1.3)
                        }
                        
                        Text("pablo 2")
                            .fontWeight(.bold)
                            .font(.caption)
                    }
                    .foregroundStyle(.ultraThickMaterial)
                    .opacity(0.65)
                    
                    
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.05)) {
                            listButton.toggle()
                        }
                    } label: {
                        customButtonLabel(imageName: "list.bullet", toggleButton: listButton, paddingEdges: .vertical, paddingLength: 1, toggleColor: song.averageColor)
                            .scaleEffect(1.3)
                    }
                }
                .padding(.top, spacing)
                
                
            }
            .frame(alignment: .bottom)
        }
        .offset(y: animateContent ? 0 : size.height)
    }
    
    @ViewBuilder
    func SongHeaderAndShareView(_ title: String, artist: String) -> some View {
        HStack(alignment: .center, spacing: 15) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(minimizedImage ? .subheadline : .title3 )
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text(artist)
                    .font(minimizedImage ? .footnote : .body)
                    .foregroundStyle(.ultraThickMaterial)
                    .opacity(0.65)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Menu {
                ForEach(vm.dropDownMenuItems.indices.sorted(), id: \.self) { index in
                    Button {

                    } label: {
                        HStack {
                            Text(vm.dropDownMenuItems[index].key)
                            Image(systemName: vm.dropDownMenuItems[index].value)
                        }
                    }
                }
            } label: {
                ZStack {
                    
                    Circle()
                        .fill(.ultraThinMaterial)
                        .opacity(0.2)
                    
                    Image(systemName: "ellipsis")
                        .foregroundColor(.white)
                }
                .frame(width: 30, height: 30)
            }
        }
    }
    
    @ViewBuilder
    func SongImageAndHeaderShareView(_ size: CGSize) -> some View {
        let song = vm.songs[vm.currentSong]
//        let spacing = size.height * 0.04

        var imageFrame: CGSize {
            minimizedImage ? CGSize(width: 60, height: 60) : CGSize(width: size.width - 50, height: size.width - 50)
        }
        VStack {
            HStack(spacing: 15) {
                ZStack {
                    Image(uiImage: song.image!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: animateContent ? (minimizedImage ? 5 : 10) : 5, style: .continuous))
                        .scaleEffect(minimizedImage ? 1 : isPlaying ? 1 : 0.75)
                        .shadow(
                            color: Color.black
                                .opacity(minimizedImage ? 0 : isPlaying ? 0.65 : 0.3),
                            radius: 20,
                            y: minimizedImage ? 0 : isPlaying ? 10 : 5)
                        .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.6), value: isPlaying)
                        .matchedGeometryEffect(id: "ICON1", in: animation)
                        .padding(.vertical, minimizedImage ? 0 : size.height > 700 ? 30 : 10)
                }
                .frame(width: imageFrame.width, height: imageFrame.height)
                
                if minimizedImage {
                    SongHeaderAndShareView(song.title, artist: song.artist)
                        .matchedGeometryEffect(id: "SongHeaderAndShareView", in: animation)
                }
            }
            
            if minimizedImage {
                SongsList(songs: $vm.songs, currentSong: song)
                    .frame(height: size.height/2)
                    .border(.white)
            }
        }

    }
    
    @ViewBuilder
    func customButtonLabel(imageName: String, toggleButton: Bool, paddingEdges: Edge.Set = .all, paddingLength: CGFloat = 0, toggleColor: Color) -> some View {
        Image(systemName: imageName)
            .foregroundColor(toggleButton ? toggleColor : Color.white)
            .foregroundStyle(toggleButton ? Material.regularMaterial : .ultraThickMaterial)
            .opacity(toggleButton ? 1 : 0.65)
            .padding(paddingEdges, paddingLength)
            .padding(.vertical, 4)
            .padding(.horizontal, 2)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(.white)
                    .foregroundStyle(.ultraThickMaterial)
                    .scaleEffect(toggleButton ? 1 : 0.6)
                    .opacity(toggleButton ? 0.65 : 0)
                
            }
    }
}


struct ExpandedView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}

struct ControlButton< Content: View>: View {
    let completion: () -> Void
    @ViewBuilder let content: Content
    
    
    @State private var showBackground = false
    
    init(_ completion: @escaping () -> Void, content: @escaping () -> Content) {
        self.completion = completion
        self.content = content()
    }
    
    var body: some View {
        Button {
            completion()
                showBackground = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    showBackground = false
            }
        } label: {
            content
                .background(
                    Circle()
                    .fill(.gray)
                    .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.6), value: showBackground)
                    .opacity(showBackground ? 0.5 : 0)
                    .padding(showBackground ? -15 : -10)
                )
        }
    }
}

struct RunningLine: View {
    let text: String
    @State private var xOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Text(text)
                    .foregroundColor(.white)
                Text(text)
                    .foregroundColor(.blue)
                    .frame(height: 2)
                    .offset(x: xOffset)
            }
            .onAppear {
                withAnimation(Animation.linear(duration: 3).repeatForever()) {
                    xOffset = geometry.size.width
                }
            }
        }
    }
}






