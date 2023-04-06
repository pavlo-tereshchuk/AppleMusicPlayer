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
    @State private var offsetY: CGFloat = 0
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            let safeArea = $0.safeAreaInsets
            
            ZStack {
                RoundedRectangle(cornerRadius: animateContent ? deviceCornerRadius : 0, style: .continuous)
                    .fill(.ultraThickMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: animateContent ? deviceCornerRadius : 0, style: .continuous)
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
                    .offset(y: animateContent ? 0 : size.height)
                
                    GeometryReader {
                        let size = $0.size
                        Image("Icon1")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .clipShape(RoundedRectangle(cornerRadius: animateContent ? 15 : 5, style: .continuous))
                    }
                    .matchedGeometryEffect(id: "ICON1", in: animation)
                    .frame(height: size.width - 50)
                    .padding(.vertical, size.height > 700 ? 30 : 10)
                    
                    PlayerView(size)
                        .offset(y: animateContent ? 0 : size.height)
                }
                .padding(.top, safeArea.top + (safeArea.bottom == 0 ? 10 : 0))
                .padding(.bottom, safeArea.bottom == 0 ? 10 : safeArea.bottom)
                .padding(.horizontal, 25)
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
                                expandScheet = false
                                animateContent = false
                            }
                        } else {
                            offsetY = .zero
                        }
                    })
            )
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.35)) {
                animateContent = true
            }
        }
    }
    
    @ViewBuilder
    func PlayerView(_ size: CGSize) -> some View{
        GeometryReader {
            let size = $0.size
            let spacing = size.height * 0.04
            
            VStack(spacing: spacing) {
                
                VStack(spacing: spacing) {
                    HStack(alignment: .center, spacing: 15) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Accordion")
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text("MF DOOM")
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Button {
                            
                        } label: {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.white)
                                .padding(12)
                                .background {
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .environment(\.colorScheme, .light)
                                }
                        }
                        
                        
                    }
                    
                    VStack(spacing: spacing) {
                        Capsule()
                            .fill(.gray)
                            .frame(height: 7)
                        HStack {
                            Text("0:00")
                            
                            Spacer()
                            
                            Text("-1:59")
                        }
                        .font(.caption2)
                        .foregroundColor(.gray)
                        
                    }
   
                }
                .frame(height: size.height/2.5, alignment: .top)
                
//                Play controls
                HStack(spacing: size.width * 0.2) {
                    Button {
                        
                    } label: {
                        Image(systemName: "backward.fill")
                            .font(size.height < 300 ? .title3 : .title2)
                    }
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "pause.fill")
                            .font(size.height < 300 ? .largeTitle : .system(size: 50))
                    }
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "forward.fill")
                            .font(size.height < 300 ? .title3 : .title2)
                    }
                }
                .foregroundColor(.white)
                .frame(maxHeight: .infinity)
                
//                Volume and below
                VStack(spacing: spacing) {
                    HStack(spacing: 15) {
                        
                        Image(systemName: "speaker.fill")
                            .foregroundColor(.white)
                        
                        Capsule()
                            .fill(.gray)
                            .frame(height: 7)
                        
                        Image(systemName: "speaker.wave.3.fill")
                            .foregroundColor(.white)
                    }
                    .padding(.top, spacing * 2)
                    
                    HStack(alignment: .top, spacing: size.width * 0.2) {
                        Button {
                            
                        } label: {
                            Image(systemName: "quote.bubble")
                        }
                        
                        VStack(spacing: 6) {
                            Button {
                                
                            } label: {
                                Image(systemName: "airpods")
                            }
                            
                            Text("pablo 2")
                                .font(.caption)
                        }
                        
                        Button {
                            
                        } label: {
                            Image(systemName: "list.bullet")
                        }
                    }
                    .foregroundColor(.white)
                    .font(.title2)
                    .blendMode(.overlay)
                    .padding(.top, spacing)
                }
                .frame(height: size.height/2.5, alignment: .bottom)
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

extension View {
    var deviceCornerRadius: CGFloat {
        let key = "_displayCornerRadius"
        if let screen = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.screen {
            if let cornerRadius = screen.value(forKey: key) as? CGFloat {
                return cornerRadius
            }
        }
     return 0
    }
}
