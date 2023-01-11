//
//  CalorieCounter.swift
//  BlueEagleTests
//
//  Created by Randy Morgan on 2023/01/11.
//

@testable import BlueEagle
import XCTest

final class CalorieCounterTest: XCTestCase {
    var subject: CalorieCounter?

    func addSample(_ heartRate: Int, at: Int = 0) {
        subject?.addSample(HRSample(rate: heartRate, at: Date().addingTimeInterval(TimeInterval(at))))
    }

    func configure(_ sex: String, _ age: Int, _ weight: Int) {
        Preferences.standard.sex = sex
        Preferences.standard.age = age
        Preferences.standard.weight = weight
    }

    override func setUpWithError() throws {
        subject = CalorieCounter()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddSampleExcludesRateUnder90() throws {
        subject?.addSample(HRSample(rate: subject!.minimumViableHeartRate - 1, at: Date()))
        XCTAssertEqual(subject!.samples.count, 0)
    }

    func testAddSampleSingle() throws {
        subject?.addSample(HRSample(rate: 150, at: Date()))
        XCTAssertEqual(subject!.samples.count, 1)
        XCTAssertEqual(subject!.samples.last?.rate, 150)
    }

    func testCaloriesPerMinuteOneMaleSample() throws {
        let heartRate = 150
        let age = 35
        let weight = 95

        configure(Sex.male.rawValue, age, weight)

        var bigCheat = -55.0960
        bigCheat += 0.6309 * Double(heartRate)
        bigCheat += 0.1988 * Double(weight)
        bigCheat += 0.2017 * Double(age)
        bigCheat = bigCheat / 4.1845

        XCTAssertEqual(subject!.caloriesPerMinute(heartRate), Int(bigCheat))
    }

    func testCaloriesOnePerMinuteFemaleSample() throws {
        let heartRate = 150
        let age = 35
        let weight = 95

        configure(Sex.female.rawValue, age, weight)

        var bigCheat = -20.4022
        bigCheat += 0.4472 * Double(heartRate)
        bigCheat += 0.1263 * Double(weight)
        bigCheat += 0.074 * Double(age)
        bigCheat = bigCheat / 4.1845

        XCTAssertEqual(subject!.caloriesPerMinute(heartRate), Int(bigCheat))
    }

    func testCaloriesNoSample() throws {
        XCTAssertEqual(subject!.calories(), 0)
    }

    func testCaloriesAroundMinimumSampleRatePerMinute() throws {
        let heartRate = subject!.minimumViableHeartRate + 1
        let age = 35
        let weight = 95

        configure(Sex.undeclared.rawValue, age, weight)
        var bigCheat = -37.74955
        bigCheat += 0.53905 * Double(heartRate)
        bigCheat += 0.16255 * Double(weight)
        bigCheat += 0.13785 * Double(age)
        bigCheat = bigCheat / 4.1845

        for _ in 1 ..< subject!.minimumSampleRatePerMinute {
            addSample(heartRate, at: 1)
        }

        XCTAssertEqual(subject!.calories(), 0)

        addSample(heartRate, at: 1)

        XCTAssertEqual(subject!.calories(), Int(bigCheat))
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        let heartRate = subject!.minimumViableHeartRate
        let age = 35
        let weight = 95
        let duration = 3600
        let MaxHRIncrease = subject!.maximumMeasurableHeartRate - heartRate
        configure(Sex.undeclared.rawValue, age, weight)

        for i in 1 ... duration {
            addSample(heartRate + Int(MaxHRIncrease * i / duration), at: 1 + i)
        }
        // This is an example of a performance test case.
        measure {
            XCTAssertEqual(subject!.calories(), 642)
            // Put the code you want to measure the time of here.
        }
    }
}
