//
//  TimeIntervalTests.swift
//  tabBarTests
//
//  Created by Pavlo Tereshchuk on 17.10.26.
//

import XCTest
import SwiftUI
@testable import tabBar

final class TimeIntervalTests: XCTestCase {

    // MARK: - minuteSecond

    func testPadsSecondsBelowTen() {
        // GIVEN a position one minute and five seconds into a track
        let position: TimeInterval = 65

        // WHEN it is formatted for the player's time label
        let label = position.minuteSecond

        // THEN the seconds are zero-padded to two digits
        XCTAssertEqual(label, "1:05")
    }

    func testFormatsStartOfTrackAsZero() {
        // GIVEN a track sitting at its very beginning
        let position: TimeInterval = 0

        // WHEN it is formatted
        let label = position.minuteSecond

        // THEN both components read zero
        XCTAssertEqual(label, "0:00")
    }

    func testFormatsWholeMinuteWithoutLeftoverSeconds() {
        // GIVEN a position exactly two minutes in
        let position: TimeInterval = 120

        // WHEN it is formatted
        let label = position.minuteSecond

        // THEN the seconds read zero rather than being dropped
        XCTAssertEqual(label, "2:00")
    }

    func testFormatsLastSecondBeforeAMinuteRolls() {
        // GIVEN a position one second short of ten minutes
        let position: TimeInterval = 599

        // WHEN it is formatted
        let label = position.minuteSecond

        // THEN minutes and seconds are both at their maximum for that minute
        XCTAssertEqual(label, "9:59")
    }

    func testTruncatesFractionalSecondsInsteadOfRounding() {
        // GIVEN a playback position reported with a fraction, as AVAudioPlayer does
        let position: TimeInterval = 65.9

        // WHEN it is formatted
        let label = position.minuteSecond

        // THEN the fraction is dropped, so the label never shows a second early
        XCTAssertEqual(label, "1:05")
    }

    // MARK: - Binding.onChange

    func testOnChangeRunsHandlerWithTheNewValue() {
        // GIVEN a binding wrapped so the player is told about scrubbing
        var stored: TimeInterval = 0
        var observed: [TimeInterval] = []
        let binding = Binding<TimeInterval>(get: { stored }, set: { stored = $0 })
            .onChange { observed.append($0) }

        // WHEN a new value is written through the binding
        binding.wrappedValue = 42

        // THEN the handler sees that value, and the store is already updated
        XCTAssertEqual(observed, [42])
        XCTAssertEqual(stored, 42)
    }

    func testOnChangeStaysSilentUntilWritten() {
        // GIVEN a wrapped binding that nobody has written to
        var stored: TimeInterval = 7
        var observed: [TimeInterval] = []
        let binding = Binding<TimeInterval>(get: { stored }, set: { stored = $0 })
            .onChange { observed.append($0) }

        // WHEN only the current value is read
        let value = binding.wrappedValue

        // THEN reading does not trigger a seek on the audio player
        XCTAssertEqual(value, 7)
        XCTAssertTrue(observed.isEmpty)
    }
}
