//
//  AudioServiceTest.swift
//  BlueEagleTests
//
//  Created by Randy Morgan on 2024/10/21.
//

import XCTest
@testable import BlueEagle

final class AudioServiceTest: XCTestCase {
    let sut = AudioService.shared
    
    func testPlayAlarm() {
        sut.play(.alarm)
        XCTAssertTrue(sut.isPlaying)
    }
}
