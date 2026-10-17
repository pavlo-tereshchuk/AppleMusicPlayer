//
//  SongStatus.swift
//  tabBar
//
//  Created by Pavlo Tereshchuk on 18.04.23.
//

import SwiftUI

/// A playback scrubber that thickens while the user drags it.
///
/// Dragging is relative rather than absolute: the bar tracks how far the
/// gesture has moved since the last update instead of jumping to wherever the
/// finger landed, which is what lets the user fine-tune a position from
/// anywhere along the bar.
///
/// The bound position is only written back once the gesture ends, so the
/// player isn't seeking continuously mid-drag. Until then the labels and fill
/// preview the pending position.
struct SongStatus: View {

    // MARK: - Public properties

    let spacing: CGFloat

    /// The playback position in seconds, updated when a drag ends.
    @Binding var status: TimeInterval

    /// The track length in seconds, used to convert between position and
    /// progress.
    let duration: TimeInterval

    // MARK: - Private properties

    /// Whether a drag is in progress. Starting one seeds ``newStatus`` with
    /// the current progress so the bar doesn't jump.
    @State private var isPressed: Bool = false {
        didSet {
            if isPressed && !oldValue {
                newStatus = Double(status/duration)
            }
        }
    }

    /// The pending progress, from `0` to `1`, shown while dragging.
    @State private var newStatus: Double = 0

    /// The previous drag translation, used to derive each incremental step.
    @State private var oldTranslation: Double = 0

    // MARK: - Init

    /// Creates a scrubber.
    ///
    /// - Parameters:
    ///   - spacing: Reserved for layout spacing.
    ///   - status: A binding to the playback position, in seconds.
    ///   - duration: The track length, in seconds.
    init(spacing: CGFloat, status: Binding<TimeInterval>, duration: TimeInterval) {
        self.spacing = spacing
        self._status = status
        self.duration = duration
    }

    // MARK: - Body

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
