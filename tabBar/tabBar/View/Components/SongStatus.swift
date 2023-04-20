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
    @State private var isPressed: Bool = false
    @State private var newStatus: Double = 0
    
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
            
            VStack(alignment: .center, spacing: spacing) {
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(.gray)
                        .frame(height: isPressed ? 12 : 7)
                        .overlay(alignment: .leading) {
                            Rectangle()
                                .fill(isPressed ? .white : Color(UIColor.lightGray))
                                .frame(height: isPressed ? 12 : 7)
                                .scaleEffect(x: progress, anchor: .leading)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    
                }
                
                HStack {
                    Text(isPressed ? (newStatus * duration).minuteSecond : status.minuteSecond)
                    
                    Spacer()
                    
                    Text(isPressed ? "-\((duration - (newStatus * duration)).minuteSecond)" : "-\((duration - status).minuteSecond)")
                }
                .font(.caption2)
                .foregroundColor(isPressed ? .white : .gray)
                
            }
            .padding(.horizontal, isPressed ? 0 : 5)
            .padding(.top, isPressed ? 0 : 2.5)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ value in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isPressed = true
                        }
                        let x = value.location.x
                        self.newStatus = x >= width ? self.newStatus : x/width
                    })
                    .onEnded({ value in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            self.status = self.newStatus * self.duration
                            isPressed = false
                        }
                    }))
            
        }
    }
}

struct SongStatus_Previews: PreviewProvider {
    @State static var status = TimeInterval(0.1)
    static var previews: some View {
        SongStatus(spacing: 10, status: $status, duration: 144)
            .preferredColorScheme(.dark)
        
    }
}
