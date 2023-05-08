//
//  VolumeStatus.swift
//  tabBar
//
//  Created by Pavlo Tereshchuk on 19.04.23.
//

import SwiftUI

struct VolumeStatus: View {
    let spacing: CGFloat
    @ObservedObject var vm: HomeViewModel
    @State private var isPressed: Bool = false
    @State private var oldTranslation: Double = 0
    
    init(spacing: CGFloat, vm: HomeViewModel) {
        self.spacing = spacing
        self.vm = vm
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
                                .scaleEffect(x: vm.volume, anchor: .leading)
                                .animation(.easeIn(duration: 0.2), value: vm.volume)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    
                }
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged({ value in
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isPressed = true
                            }
                            let translation = value.translation.width
                            var realTransl = translation - oldTranslation
                            oldTranslation = translation
                            if translation != 0 {
                                realTransl = realTransl/width
                                
                                self.vm.volume += realTransl
                                
                                if (self.vm.volume + realTransl) < 0 {
                                    self.vm.volume = 0
                                }
                                
                                if (self.vm.volume + realTransl) > 1 {
                                    self.vm.volume = 1
                                }
                            }
                        })
                        .onEnded({ value in
                            withAnimation(.easeInOut(duration: 0.3)) {
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
        VolumeStatus(spacing: 10, vm: HomeViewModel())
            .preferredColorScheme(.dark)
    }
}
