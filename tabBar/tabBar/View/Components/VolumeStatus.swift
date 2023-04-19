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
    @State var progress: Double
    
    init(spacing: CGFloat, progress: Double) {
        self.spacing = spacing
        self.progress = progress
    }
    
    var body: some View {
        
            
        HStack(alignment: .center, spacing: spacing) {
            Image(systemName: "speaker.fill")
                .foregroundColor(isPressed ? .white : .gray)
            
            GeometryReader {
                let size = $0.size
                let width = size.width
                
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
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged({ value in
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isPressed = true
                            }
                            let x = value.location.x
                            self.progress = x >= width ? self.progress : x/width
                        })
                        .onEnded({ value in
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isPressed = false
                            }
                        }))
            }
            .frame(alignment: .center)
            
            Image(systemName: "speaker.wave.3.fill")
                .foregroundColor(isPressed ? .white : .gray)
        }
        .padding(.horizontal, isPressed ? 0 : 5)
        .padding(.top, isPressed ? 0 : 2.5)
        .frame(height: 10)
    }
}

struct VolumeStatus_Previews: PreviewProvider {
    static var previews: some View {
        VolumeStatus(spacing: 10, progress: 0.1)
            .preferredColorScheme(.dark)
    }
}
