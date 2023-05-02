//
//  VolumeStatus.swift
//  tabBar
//
//  Created by Pavlo Tereshchuk on 19.04.23.
//

import SwiftUI

struct VolumeStatus: View {
    let spacing: CGFloat
    @State private var isPressed: Bool = false
    @State var volume: Double
    let onVolumeSet: (Float) -> Void
    
    init(spacing: CGFloat, volume: Double, onVolumeSet: @escaping (Float) -> Void) {
        self.spacing = spacing
        self.volume = volume
        self.onVolumeSet = onVolumeSet
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
                                .scaleEffect(x: self.volume, anchor: .leading)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    
                }
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged({ value in
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isPressed = true
                            }
                            let x = value.location.x
                            self.volume = x >= width ? self.volume : x/width
                        })
                        .onEnded({ value in
                            withAnimation(.easeInOut(duration: 0.3)) {
                                onVolumeSet(Float(self.volume))
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
    static var previews: some View {
        VolumeStatus(spacing: 10, volume: 0.1, onVolumeSet: {_ in})
            .preferredColorScheme(.dark)
    }
}
