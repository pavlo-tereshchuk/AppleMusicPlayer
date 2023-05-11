//
//  VolumeStatus.swift
//  tabBar
//
//  Created by Pavlo Tereshchuk on 19.04.23.
//

import SwiftUI
import MediaPlayer

struct VolumeStatus: View {
    let spacing: CGFloat
    @Binding var volume: Float
    @State private var isPressed: Bool = false {
        didSet {
            if isPressed && !oldValue {
                newVolume = volume
            }
        }
    }
    @State private var oldTranslation: Float = 0
    @State private var newVolume: Float = 0
    
    init(spacing: CGFloat, volume: Binding<Float>) {
        self.spacing = spacing
        self._volume = volume
    }
    
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
