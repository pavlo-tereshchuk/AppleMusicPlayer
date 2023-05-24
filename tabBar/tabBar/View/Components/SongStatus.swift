//
//  SongStatus.swift
//  tabBar
//
//  Created by Pavlo Tereshchuk on 18.04.23.
//

import SwiftUI

struct SongStatus: View {
    let spacing: CGFloat
    @Binding var status: TimeInterval
    let duration: TimeInterval
    
    @State private var isPressed: Bool = false {
        didSet {
            if isPressed && !oldValue {
                newStatus = Double(status/duration)
            }
        }
    }
    @State private var newStatus: Double = 0
    @State private var oldTranslation: Double = 0
    
    init(spacing: CGFloat, status: Binding<TimeInterval>, duration: TimeInterval) {
        self.spacing = spacing
        self._status = status
        self.duration = duration
    }
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            let width = size.width
            let progress = isPressed ? self.newStatus : Double(status/duration)
            VStack(spacing: 12) {
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
                                .scaleEffect(x: progress, anchor: .leading)
                                .animation(.easeIn(duration: 0.2), value: progress)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    
                }
                
                HStack {
                    Text(isPressed ? (newStatus * duration).minuteSecond : status.minuteSecond)
                    
                    Spacer()
                    
                    Text(isPressed ? "-\((duration - (newStatus * duration)).minuteSecond)" : "-\((duration - status).minuteSecond)")
                }
                .font(.caption2)
                .foregroundColor(.white)
                .foregroundStyle(.ultraThinMaterial)
                .opacity(isPressed ? 1 : 0.2)
            }
            .padding(.horizontal, isPressed ? -5 : 0)
            .padding(.top, isPressed ? 0 : 2.5)
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
                            
                            self.newStatus += realTransl
                            
                            if (self.newStatus + realTransl) < 0 {
                                self.newStatus = 0
                            }
                            
                            if (self.newStatus + realTransl) > 1 {
                                self.newStatus = 1
                            }
                        }
                    })
                    .onEnded({ value in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            if oldTranslation != 0 {
                                self.status = self.newStatus * self.duration
                            }
                            isPressed = false
                            oldTranslation = 0
                        }
                    }))
            }
    }
}

struct SongStatus_Previews: PreviewProvider {
    @State static var status = TimeInterval(55)
    static var previews: some View {
        SongStatus(spacing: 10, status: $status, duration: 144)
            .environment(\.colorScheme, .light)
            .preferredColorScheme(.dark)
        
    }
}
