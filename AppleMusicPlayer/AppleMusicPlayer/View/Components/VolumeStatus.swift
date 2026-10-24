//
//  VolumeStatus.swift
//  AppleMusicPlayer
//
//  Created by Pavlo Tereshchuk on 19.04.23.
//

import SwiftUI
import MediaPlayer

/// A system volume slider that thickens while the user drags it.
///
/// Shares the relative-drag behavior of ``SongStatus``: the bar follows how far
/// the gesture has moved rather than jumping to the touch location, and the
/// new level is applied only when the gesture ends.
///
/// Volume is written by reaching into `MPVolumeView`'s private `UISlider`,
/// since there's no public API for setting system volume from an app.
struct VolumeStatus: View {

    // MARK: - Public properties

    let spacing: CGFloat

    /// The system volume, from `0` to `1`, updated when a drag ends.
    @Binding var volume: Float

    // MARK: - Private properties

    /// Whether a drag is in progress. Starting one seeds ``newVolume`` with
    /// the current level so the bar doesn't jump.
    @State private var isPressed: Bool = false {
        didSet {
            if isPressed && !oldValue {
                newVolume = volume
            }
        }
    }

    /// The previous drag translation, used to derive each incremental step.
    @State private var oldTranslation: Float = 0

    /// The pending volume shown while dragging.
    @State private var newVolume: Float = 0

    // MARK: - Init

    /// Creates a volume slider.
    ///
    /// - Parameters:
    ///   - spacing: The gap between the slider and its speaker icons.
    ///   - volume: A binding to the system volume, from `0` to `1`.
    init(spacing: CGFloat, volume: Binding<Float>) {
        self.spacing = spacing
        self._volume = volume
    }

    // MARK: - Body

    var body: some View {
        HStack(alignment: .center, spacing: spacing) {
            Image(systemName: "speaker.fill")
                .foregroundColor(.white)
                .foregroundStyle(.ultraThickMaterial)
                .opacity(isPressed ? 1 : 0.65)
            
            GeometryReader {
                let size = $0.size
                let width = size.width
                let vol = isPressed ? self.newVolume : volume

                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .opacity(0.2)
                        .frame(height: isPressed ? 14 : 7)
                        .overlay(alignment: .leading) {
                            Rectangle()
                                .fill(.white)
                                .opacity(isPressed ? 1 : 0.65)
                                .frame(height: isPressed ? 14 : 7)
                                .scaleEffect(x: CGFloat(vol), anchor: .leading)
                                .animation(.easeIn(duration: 0.2), value: vol)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged({ value in
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isPressed = true
                            }
                            let translation = Float(value.translation.width)
                            var realTransl = translation - oldTranslation
                            oldTranslation = translation
                            if translation != 0 {
                                realTransl = realTransl/Float(width)
                                
                                self.newVolume += realTransl
                                
                                if (self.newVolume + realTransl) < 0 {
                                    self.newVolume = 0
                                }
                                
                                if (self.newVolume + realTransl) > 1 {
                                    self.newVolume = 1
                                }
                            }
                        })
                        .onEnded({ value in
                            withAnimation(.easeInOut(duration: 0.3)) {
                                if let view = MPVolumeView().subviews.first as? UISlider
                                {
                                     view.value = newVolume
                                }
                                volume = newVolume
                                isPressed = false
                                
                            }
                        }))
            }
            .frame(alignment: .center)
            
            Image(systemName: "speaker.wave.3.fill")
                .foregroundColor(.white)
                .foregroundStyle(.ultraThickMaterial)
                .opacity(isPressed ? 1 : 0.65)
        }
        .padding(.horizontal, isPressed ? 0 : 5)
        .padding(.top, isPressed ? 0 : 2.5)
        .frame(height: 10)
    }
}

struct VolumeStatus_Previews: PreviewProvider {
    @State static var volume: Float = 0.1
    
    static var previews: some View {
        VolumeStatus(spacing: 10, volume: $volume)
            .preferredColorScheme(.dark)
    }
}
