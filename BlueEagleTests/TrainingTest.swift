//
//  TrainingTest.swift
//  BlueEagleTests
//
//  Created by Randy Morgan on 2021/10/28.
//

import XCTest
@testable import BlueEagle
class TrainingTest: XCTestCase {
    var subject: Training?
    override func setUpWithError() throws {
        try super.setUpWithError()
        subject = Training()
        // subject!.age = 47
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        subject = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_addSample() throws {
        subject?.addSample(sample: HRSample(rate: 50, at: Date()))
        XCTAssertEqual(subject!.samples.count, 1)
    }
    
    func test_currentTrainingZone() throws {
        subject?.addSample(sample: HRSample(rate: 138, at: Date()))
        XCTAssertEqual(subject!.currentTrainingZone.description, GarminTraining().zones[3].description)
    }
/*
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
*/
}
