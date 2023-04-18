//
//  SongStatus.swift
//  tabBar
//
//  Created by Pavlo Tereshchuk on 18.04.23.
//

import SwiftUI

struct SongStatus: View {
    let spacing: CGFloat
    @State private var isPressed: Bool = false {
        didSet {
            if isPressed && !oldValue {
                progressWidth += 10
            }
            if !isPressed && oldValue{
                progressWidth -= 10
            }
        }
    }
    @State private var progressWidth: CGFloat = 0
    
    init(_ spacing: CGFloat) {
        self.spacing = spacing
    }
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            let width = size.width
            
            VStack(alignment: .center, spacing: spacing) {
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(.gray)
                        .frame(height: isPressed ? 12 : 7)
                        .overlay(alignment: .leading) {
                            Rectangle()
                                .fill(isPressed ? .white : Color(UIColor.lightGray))
                                .frame(width: self.progressWidth, height: isPressed ? 12 : 7)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    
                }
                
                HStack {
                    Text("0:00")
                    
                    Spacer()
                    
                    Text("-1:59")
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
                        self.progressWidth = x > width ? self.progressWidth : x
                    })
                    .onEnded({ value in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isPressed = false
                        }
                    }))
            
        }
    }
}

struct SongStatus_Previews: PreviewProvider {
    static var previews: some View {
        SongStatus(10)
            .preferredColorScheme(.dark)
        
    }
}
