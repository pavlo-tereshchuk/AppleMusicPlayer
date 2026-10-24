//
//  ExpandedView.swift
//  AppleMusicPlayer
//
//  Created by Pavlo Tereshchuk on 31.03.23.
//

import SwiftUI
import MediaPlayer


/// The full-screen now-playing view.
///
/// Presented as an overlay from ``HomeView`` and dismissed by dragging down.
/// The artwork and background arrive via `matchedGeometryEffect` from the mini
/// player, while `animateContent` slides the controls up a beat later to
/// reproduce Apple Music's staggered entrance.
///
/// Since `AVAudioPlayer` reports no progress, this view also acts as the
/// player's clock: a timer polls playback position, play/pause state and
/// system volume, pushing each into ``HomeViewModel``, and advances the queue
/// when a track ends.
struct ExpandedSongView: View {

    // MARK: - Public properties

    /// Set to `false` when the sheet is dragged far enough to dismiss.
    @Binding var expandScheet: Bool

    @Binding var isPlaying: Bool
    @ObservedObject var vm: HomeViewModel

    /// The geometry namespace shared with ``HomeView``.
    var animation: Namespace.ID

    /// Polls the audio player, which has no progress callbacks of its own.
    let timer = Timer.publish(every: 0.25, on: .main, in: .common)
        .autoconnect()

    // MARK: - Private properties

    /// Drives the entrance animation: the controls and corner radius are tied
    /// to this rather than to `expandScheet`, which lets them lag behind the
    /// matched-geometry transition.
    @State private var animateContent: Bool = false

    /// The sheet's drag offset, in points.
    @State private var offsetY: CGFloat = 0

    // MARK: - Body

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

                        
                    SongImageAndHeaderShareView(size)
                        .frame(height: vm.minimizedImage ? (size.height/2.03 + size.height/7) : size.height/2.075)
                        .animation(.easeInOut(duration: 0.3), value: vm.minimizedImage)
                        
                    
                    PlayerView(size)
                        .padding(.horizontal, 25)
                    
                }
                .padding(.top, safeArea.top + (safeArea.bottom == 0 ? 10 : 0))
                .padding(.bottom, safeArea.bottom == 0 ? 10 : safeArea.bottom)
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
                                offsetY = size.height
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
            self.isPlaying = self.vm.isPlaying()
//            Song status
            if vm.isFinished() {
                vm.playNext()
            } else {
                vm.currentTime = vm.getCurrentTime() ?? vm.currentTime
            }
            
//            Volume
            let vol = vm.getVolume()
//            for better UX because sound changes new via levels 0.05 each
            if abs(vm.volume - vol) >= 0.05 {
                vm.volume = vol
            }
        }
    }
    
    // MARK: - Public methods

    /// The lower half of the sheet: title, scrubber, transport controls,
    /// volume and the lyrics/queue toggles.
    ///
    /// The title and scrubber are hidden while a panel is open, since they move
    /// up next to the minimized artwork.
    ///
    /// - Parameter size: The size of the enclosing sheet, used to scale
    ///   spacing and control sizes to the device.
    @ViewBuilder
    func PlayerView(_ size: CGSize) -> some View{
        let song = vm.songs[vm.currentSong]
        let spacing = size.height * 0.04
        VStack {
            ZStack {
                if (!vm.minimizedImage) {
                    VStack(spacing: 20) {
                        SongHeaderAndShareView(song.title, artist: song.artist)
                            .matchedGeometryEffect(id: "SongHeaderAndShareView", in: animation)
                        
                        SongStatus(spacing: spacing,
                                   status: $vm.currentTime.onChange({vm.setCurrentTime($0)}),
                                   duration: song.duration)
                        
                        
                    }
                    .frame(height: size.height/7)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: vm.minimizedImage)

            

            //Play controls
            
            GeometryReader {
                let size = $0.size

                HStack(alignment: .center, spacing: size.width * 0.18) {
                    ControlButton {
                        if (vm.currentTime < 5) {
                            vm.playPrev()
                        } else {
                            vm.setCurrentTime(0)
                        }
                    } content: {
                        Image(systemName: "backward.fill")
                            .font(size.height < 90 ? .title2 : .title)
                    }

                    ControlButton {
                        vm.pause_play()
                    } content: {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(size.height < 90 ? .largeTitle : .system(size: 40))
                            .animation(.easeInOut(duration: 0.3), value: isPlaying)
                    }



                    ControlButton {
                        vm.playNext()
                    } content: {
                        Image(systemName: "forward.fill")
                            .font(size.height < 90 ? .title2 : .title)
                    }

                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.bottom, 10)



            }
            .frame(maxHeight: .infinity)
            .padding(.bottom, 10)

            //Volume + Bottom buttons
            
            VStack {
                
                VolumeStatus(spacing: 15, volume: $vm.volume.onChange({vm.setVolume($0)}))
                
                HStack(alignment: .top, spacing: size.width * 0.18) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.05)) {
                            vm.quoteButton.toggle()
                        }
                    } label: {
                        customButtonLabel(imageName: vm.quoteButton ? "quote.bubble.fill" : "quote.bubble", toggleButton: vm.quoteButton, toggleColor: song.averageColor)
                            
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
                            vm.listButton.toggle()
                        }
                    } label: {
                        customButtonLabel(imageName: "list.bullet", toggleButton: vm.listButton, paddingEdges: .vertical, paddingLength: 1, toggleColor: song.averageColor)
                            .scaleEffect(1.3)
                    }
                }
                .padding(.top, spacing)
                
                
            }
            .frame(alignment: .bottom)
        }
        .offset(y: animateContent ? 0 : size.height)
    }
    
    /// The track title and artist, with the context menu button alongside.
    ///
    /// This moves between two places depending on ``HomeViewModel/minimizedImage``
    /// — below the full-size artwork, or to its right once it shrinks — and is
    /// matched across both positions so the text slides rather than jumps.
    ///
    /// - Parameters:
    ///   - title: The track title.
    ///   - artist: The performing artist.
    @ViewBuilder
    func SongHeaderAndShareView(_ title: String, artist: String) -> some View {
        HStack(alignment: .center, spacing: 15) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(vm.minimizedImage ? .subheadline : .title3 )
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text(artist)
                    .font(vm.minimizedImage ? .footnote : .body)
                    .foregroundStyle(.ultraThickMaterial)
                    .opacity(0.65)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .animation(.easeInOut(duration: 0.3), value: vm.minimizedImage)
            
            Menu {
                ForEach(vm.dropDownMenuItems.indices.sorted(by: >), id: \.self) { index in
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
    
    /// The upper half of the sheet: the artwork, and the lyrics or queue panel
    /// when one is open.
    ///
    /// The artwork fills the width while nothing else is showing and collapses
    /// to a 60-point thumbnail to make room for a panel. It also breathes with
    /// playback, scaling down and dropping its shadow when paused.
    ///
    /// - Parameter size: The size of the enclosing sheet.
    @ViewBuilder
    func SongImageAndHeaderShareView(_ size: CGSize) -> some View {
        let song = vm.songs[vm.currentSong]
        var imageFrame: CGSize {
            vm.minimizedImage ? CGSize(width: 60, height: 60) : CGSize(width: size.width - 50, height: size.width - 50)
        }
        
        VStack {
            HStack(spacing: 15) {
                ZStack {
                    Image(uiImage: song.image!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: animateContent ? (vm.minimizedImage ? 5 : 10) : 5, style: .continuous))
                        .scaleEffect(vm.minimizedImage ? 1 : isPlaying ? 1 : 0.75)
                        .shadow(
                            color: Color.black
                                .opacity(vm.minimizedImage ? 0 : isPlaying ? 0.65 : 0.3),
                            radius: 20,
                            y: vm.minimizedImage ? 0 : isPlaying ? 10 : 5)
                        .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.6), value: isPlaying)
                        .matchedGeometryEffect(id: "ICON1", in: animation)
                        .padding(.vertical, vm.minimizedImage ? 0 : size.height > 700 ? 30 : 10)
                }
                .frame(width: imageFrame.width, height: imageFrame.height)
                
                if vm.minimizedImage {
                    SongHeaderAndShareView(song.title, artist: song.artist)
                        .matchedGeometryEffect(id: "SongHeaderAndShareView", in: animation)
                }
                
            }
            .animation(.easeInOut(duration: 0.3), value: vm.minimizedImage)
            .padding(.horizontal, 25)

            
            if vm.listButton {
                SongsList(expandScheet: expandScheet, vm: vm)
                    .frame(height: size.height/2)
            }
            
            if vm.quoteButton {
                LyricsView(expandScheet: expandScheet, lyrics: song.lyrics)
                    .frame(height: size.height/2)
                    .padding(.horizontal, 25)
            }
            
        }

    }
    
    /// A toggle button label that grows a tinted rounded background when on.
    ///
    /// - Parameters:
    ///   - imageName: The SF Symbol name for the icon.
    ///   - toggleButton: Whether the button is currently on.
    ///   - paddingEdges: The edges to apply `paddingLength` to.
    ///   - paddingLength: Extra inset used to even out differently
    ///     proportioned symbols.
    ///   - toggleColor: The icon tint when on, normally the artwork's
    ///     dominant color.
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

/// A transport button that flashes a circular highlight when tapped.
///
/// The highlight is driven by a timed state change rather than the button's
/// pressed state, so it blooms and fades on its own even for a quick tap —
/// which is what makes Apple Music's skip buttons feel responsive.
struct ControlButton< Content: View>: View {

    // MARK: - Public properties

    let completion: () -> Void
    @ViewBuilder let content: Content

    // MARK: - Private properties

    @State private var showBackground = false

    // MARK: - Init

    /// Creates a transport button.
    ///
    /// - Parameters:
    ///   - completion: The action to run when the button is tapped.
    ///   - content: The button's icon.
    init(_ completion: @escaping () -> Void, content: @escaping () -> Content) {
        self.completion = completion
        self.content = content()
    }

    // MARK: - Body

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

/// Text with a colored highlight that sweeps across it on a loop.
///
/// - Note: An experiment toward karaoke-style lyric highlighting; not used by
///   the player yet.
struct RunningLine: View {

    // MARK: - Public properties

    let text: String

    // MARK: - Private properties

    @State private var xOffset: CGFloat = 0

    // MARK: - Body

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






