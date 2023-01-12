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
    var training: Training?

    func addSample(_ heartRate: Int, at: Int = 0) {
        training!.addSample(heartRate, Date().addingTimeInterval(Double(at)))
    }

    func configure(_ sex: String, _ age: Int, _ weight: Int) {
        Preferences.standard.sex = sex
        Preferences.standard.age = age
        Preferences.standard.weight = weight
    }

    override func setUpWithError() throws {
        subject = CalorieCounter()
        training = Training()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCaloriesPerMinuteOneMaleSample() throws {
        let heartRate = 150
        let age = 35
        let weight = 95

        configure(Sex.male.rawValue, age, weight)

        var bigCheat: Double = -55.0960
        bigCheat += 0.6309 * Double(heartRate)
        bigCheat += 0.1988 * Double(weight)
        bigCheat += 0.2017 * Double(age)
        bigCheat = bigCheat / 4.1845

        XCTAssertEqual(subject!.caloriesPerMinute(heartRate), Int(bigCheat.rounded()))
    }

    func testCaloriesOnePerMinuteFemaleSample() throws {
        let heartRate = 150
        let age = 35
        let weight = 95

        configure(Sex.female.rawValue, age, weight)

        var bigCheat: Double = -20.4022
        bigCheat += 0.4472 * Double(heartRate)
        bigCheat += 0.1263 * Double(weight)
        bigCheat += 0.074 * Double(age)
        bigCheat = bigCheat / 4.1845

        XCTAssertEqual(subject!.caloriesPerMinute(heartRate), Int(bigCheat.rounded()))
    }

    func testCaloriesNoSample() throws {
        XCTAssertEqual(subject!.calories(training!), 0)
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

        XCTAssertEqual(subject!.calories(training!), 0)

        addSample(heartRate, at: 1)

        XCTAssertEqual(subject!.calories(training!), Int(bigCheat.rounded()))
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        let heartRate = subject!.minimumViableHeartRate + 1
        let age = 35
        let weight = 95

        configure(Sex.undeclared.rawValue, age, weight)

        for i in 1 ... 3600 {
            addSample(heartRate + Int(80 * i / 3600), at: 1 + i)
        }
        // This is an example of a performance test case.
        measure {
            XCTAssertEqual(subject!.calories(training!), 733)
            // Put the code you want to measure the time of here.
        }
    }
}
