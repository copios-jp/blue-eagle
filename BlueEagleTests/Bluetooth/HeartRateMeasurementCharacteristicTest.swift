import XCTest
//  HeartRateMeasurementCharacteristicTest.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2024/09/18.
//
@testable import BlueEagle

final class HeartRateMeasurementCharacteristicTest: XCTestCase {
    let identifier: UUID = .init()
    let uInt16 = 1815
    let lsb: UInt8 = 23
    let msb: UInt8 = 7
   
    func makeCharacteristic(data: [UInt8]) -> HeartRateMeasurementCharacteristic {
        .init(UUID.init(), Data(data))
    }
    
    func test_uInt8_value() {
      let sut = makeCharacteristic(data: [0, 75])
      XCTAssertFalse(sut.options.contains(.uInt16Format))
      XCTAssertEqual(sut.value, 75)
    }
     
    func test_uInt16_value() {
        let sut = makeCharacteristic(data: [1, lsb, msb])
        XCTAssertTrue(sut.options.contains(.uInt16Format))
        XCTAssertEqual(sut.value, Double(uInt16))
        
    }
    
    func test_sensor_connection_unsupported() {
        let sut = makeCharacteristic(data: [0, 0])
        XCTAssertFalse(sut.options.contains(.sensorContact))
        XCTAssertEqual(sut.sensorStatus, .unsupported)
    }
     
    func test_sensor_connection_bad() {
        let sut = makeCharacteristic(data: [4, 0])
        XCTAssertTrue(sut.options.contains(.sensorContact))
        XCTAssertEqual(sut.sensorStatus, .poor)
    }

    func test_sensor_connection_good() {
        let sut = makeCharacteristic(data: [6, 0])
        XCTAssertTrue(sut.options.contains(.sensorContact))
        XCTAssertEqual(sut.sensorStatus, .good)
    }
    
    func test_energy_expended_not_available() {
        let sut = makeCharacteristic(data: [16, 0])
        XCTAssertFalse(sut.options.contains(.energyExpended))
        XCTAssertEqual(sut.energyExpended, nil)
    }
    
    func test_energy_expended_available() {
        let sut = makeCharacteristic(data: [8, 0, lsb, msb])
        XCTAssertTrue(sut.options.contains(.energyExpended))
        XCTAssertEqual(sut.energyExpended, uInt16)
    }

    func test_rrInterval() {
        let sut = makeCharacteristic(data: [16, 0, lsb, msb])
        XCTAssertTrue(sut.options.contains(.rrIntervals))
        XCTAssertEqual(sut.rrIntervals, [uInt16])
    }
    
    func test_all_options_available() {
        let sut = makeCharacteristic(data: [31, lsb, msb, lsb, msb, lsb, msb, lsb, msb])
        
        XCTAssertTrue(sut.options.contains(.uInt16Format))
        XCTAssertTrue(sut.options.contains(.sensorContact))
        XCTAssertTrue(sut.options.contains(.energyExpended))
        XCTAssertTrue(sut.options.contains(.rrIntervals))
        
        XCTAssertEqual(sut.value, Double(uInt16))
        XCTAssertEqual(sut.sensorStatus, .good)
        XCTAssertEqual(sut.energyExpended, uInt16)
        XCTAssertEqual(sut.rrIntervals, [uInt16, uInt16])
    }
}
