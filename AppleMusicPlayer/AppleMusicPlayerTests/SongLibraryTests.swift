//
//  SongLibraryTests.swift
//  AppleMusicPlayerTests
//
//  Created by Pavlo Tereshchuk on 24.10.26.
//

import XCTest
@testable import AppleMusicPlayer

final class SongLibraryTests: XCTestCase {

    // MARK: - getSongsList

    func testLoadsEverySongBundledWithTheApp() throws {
        // GIVEN the mp3 files that shipped inside the app bundle
        let bundlePath = try XCTUnwrap(Bundle.main.resourcePath)
        let files = try FileManager.default.contentsOfDirectory(atPath: bundlePath)
            .filter { $0.hasSuffix(".mp3") }
        XCTAssertFalse(files.isEmpty, "the test host carries no music")

        // WHEN the library is read
        let vm = HomeViewModel(audioPlayer: AudioPlayer.getInstance())
        let loaded = vm.getSongsList()

        // THEN every file became a song — names containing dots included
        XCTAssertTrue(loaded)
        XCTAssertEqual(vm.songs.count, files.count)
    }

    func testResolvesEveryBundledFileNameBackToItsResource() throws {
        // GIVEN the mp3 files that shipped inside the app bundle
        let bundlePath = try XCTUnwrap(Bundle.main.resourcePath)
        let files = try FileManager.default.contentsOfDirectory(atPath: bundlePath)
            .filter { $0.hasSuffix(".mp3") }

        // WHEN each one is loaded by name, as the library does
        // THEN it finds its file, so Song's init has a path to unwrap
        for file in files {
            let name = (file as NSString).deletingPathExtension
            XCTAssertNotNil(Bundle.main.path(forResource: name, ofType: "mp3"), "\(file) is unreachable by name")
        }
    }
}
