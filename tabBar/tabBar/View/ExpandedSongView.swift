//
//  ExpandedView.swift
//  tabBar
//
//  Created by Pavlo Tereshchuk on 31.03.23.
//

import SwiftUI

struct ExpandedSongView: View {
    @Binding var expandScheet: Bool
    var animation: Namespace.ID
    @State private var animateContent: Bool = false
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            let safeArea = $0.safeAreaInsets
            
            ZStack {
                Rectangle()
                    .fill(.ultraThickMaterial)
                    .overlay {
                        Rectangle()
                            .fill(Color(UIColor.darkGray))
                            .opacity(animateContent ? 1:0)
                    }
                    .overlay(alignment: .top) {
                        MusicInfo(expandScheet: $expandScheet, animation: animation)
                            .allowsHitTesting(false)
                            .opacity(animateContent ? 0:1)
                    }
                    .matchedGeometryEffect(id: "bigView", in: animation)
                    

                
                VStack(spacing: 15) {
                    
                    Capsule()
                        .fill(.gray)
                        .frame(width: 40, height: 5)
                        .opacity(animateContent ? 1 : 0)
                    
                    GeometryReader {
                        let size = $0.size
                        Image("Icon1")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    }
                    .matchedGeometryEffect(id: "ICON1", in: animation)
                    .frame(height: size.width - 50)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.top, safeArea.top + (safeArea.bottom == 0 ? 10 : 0))
                .padding(.bottom, safeArea.bottom == 0 ? 10 : safeArea.bottom)
                .padding(.horizontal, 25)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        expandScheet = false
                        animateContent = false
                    }
                }
            }
            .ignoresSafeArea(.container, edges: .all)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.35)) {
                animateContent = true
            }
        }
    }
}

struct ExpandedView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
